{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE GADTs               #-}
{-# LANGUAGE LambdaCase          #-}
{-# LANGUAGE OverloadedLists     #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE RecordWildCards     #-}
{-# LANGUAGE ScopedTypeVariables #-}

module HStream.Server.Handler.Common where

import           Control.Concurrent               (MVar, ThreadId, forkIO,
                                                   killThread, putMVar,
                                                   readMVar, swapMVar, takeMVar)
import           Control.Exception                (Handler (Handler),
                                                   SomeException (..), catches,
                                                   displayException,
                                                   onException, throwIO, try)
import           Control.Exception.Base           (AsyncException (..))
import           Control.Monad                    (forever, void, when)
import qualified Data.ByteString.Char8            as C
import           Data.Foldable                    (foldrM)
import qualified Data.HashMap.Strict              as HM
import           Data.Int                         (Int64)
import           Data.List                        (find)
import qualified Data.Map.Strict                  as Map
import           Data.Maybe                       (fromJust)
import qualified Data.Text                        as T
import qualified Data.Text.Lazy                   as TL
import qualified Data.Vector                      as V
import           Data.Word                        (Word32, Word64)
import           Database.ClickHouseDriver.Client (createClient)
import           Database.MySQL.Base              (ERRException)
import qualified Database.MySQL.Base              as MySQL
import           Network.GRPC.HighLevel           (StreamSend)
import           Network.GRPC.HighLevel.Generated
import           Network.GRPC.LowLevel.Op         (Op (OpRecvCloseOnServer),
                                                   OpRecvResult (OpRecvCloseOnServerResult),
                                                   runOps)
import qualified Z.Data.CBytes                    as CB
import           ZooKeeper.Types

import qualified Data.Aeson                       as Aeson
import           Data.IORef                       (IORef, atomicModifyIORef',
                                                   newIORef)
import           HStream.Connector.ClickHouse
import qualified HStream.Connector.HStore         as HCS
import           HStream.Connector.MySQL
import qualified HStream.Logger                   as Log
import           HStream.Processing.Connector
import           HStream.Processing.Processor     (TaskBuilder, getTaskName,
                                                   runTask)
import           HStream.Processing.Stream        (Materialized (..))
import           HStream.Processing.Type          (Offset (..), SinkRecord (..),
                                                   SourceRecord (..))
import           HStream.SQL.Codegen
import           HStream.Server.Exception
import           HStream.Server.HStreamApi        (RecordId (..),
                                                   StreamingFetchResponse)
import qualified HStream.Server.HStreamApi        as Api
import qualified HStream.Server.Persistence       as P
import qualified HStream.Store                    as HS
import qualified HStream.Store.Admin.API          as AA
import           HStream.ThirdParty.Protobuf      (Empty (Empty))
import           HStream.Utils                    (TaskStatus (..),
                                                   returnErrResp, returnResp,
                                                   textToCBytes)
import           System.IO.Unsafe                 (unsafePerformIO)

--------------------------------------------------------------------------------

groupbyStores :: IORef (HM.HashMap T.Text (Materialized Aeson.Object Aeson.Object SerMat))
groupbyStores = unsafePerformIO $ newIORef HM.empty
{-# NOINLINE groupbyStores #-}


checkpointRootPath :: CB.CBytes
checkpointRootPath = "/tmp/checkpoint"

type Timestamp = Int64


data ServerContext = ServerContext {
    scLDClient               :: HS.LDClient
  , scDefaultStreamRepFactor :: Int
  , zkHandle                 :: Maybe ZHandle
  , runningQueries           :: MVar (HM.HashMap CB.CBytes ThreadId)
  , runningConnectors        :: MVar (HM.HashMap CB.CBytes ThreadId)
  , subscribeRuntimeInfo     :: MVar (HM.HashMap SubscriptionId (MVar SubscribeRuntimeInfo))
  , cmpStrategy              :: HS.Compression
  , headerConfig             :: AA.HeaderConfig AA.AdminAPI
}

type SubscriptionId = TL.Text

instance Bounded RecordId where
  minBound = RecordId minBound minBound
  maxBound = RecordId maxBound maxBound

data RecordIdRange = RecordIdRange
  { startRecordId :: RecordId,
    endRecordId   :: RecordId
  } deriving (Show, Eq)

data SubscribeRuntimeInfo = SubscribeRuntimeInfo {
    sriLdreader         :: HS.LDSyncCkpReader
  , sriStreamName       :: T.Text
  , sriWindowLowerBound :: RecordId
  , sriWindowUpperBound :: RecordId
  , sriAckedRanges      :: Map.Map RecordId RecordIdRange
  , sriBatchNumMap      :: Map.Map Word64 Word32
  , sriStreamSends      :: V.Vector (StreamSend StreamingFetchResponse)
}

--------------------------------------------------------------------------------

insertAckedRecordId :: RecordId -> Map.Map RecordId RecordIdRange -> Map.Map Word64 Word32 -> Map.Map RecordId RecordIdRange
insertAckedRecordId recordId ackedRanges batchNumMap =
  let leftRange = lookupLTWithDefault recordId ackedRanges
      rightRange = lookupGTWithDefault recordId ackedRanges
      canMergeToLeft = isSuccessor recordId (endRecordId leftRange) batchNumMap
      canMergeToRight = isPrecursor recordId (startRecordId rightRange) batchNumMap
   in f leftRange rightRange canMergeToLeft canMergeToRight
  where
    f leftRange rightRange canMergeToLeft canMergeToRight
      | canMergeToLeft && canMergeToRight =
        let m1 = Map.delete (startRecordId rightRange) ackedRanges
         in Map.adjust (const leftRange {endRecordId = endRecordId rightRange}) (startRecordId leftRange) m1
      | canMergeToLeft = Map.adjust (const leftRange {endRecordId = recordId}) (startRecordId leftRange) ackedRanges
      | canMergeToRight =
        let m1 = Map.delete (startRecordId rightRange) ackedRanges
         in Map.insert recordId (rightRange {startRecordId = recordId}) m1
      | otherwise = Map.insert recordId (RecordIdRange recordId recordId) ackedRanges

lookupLTWithDefault :: RecordId -> Map.Map RecordId RecordIdRange -> RecordIdRange
lookupLTWithDefault recordId ranges = maybe (RecordIdRange minBound minBound) snd $ Map.lookupLT recordId ranges

lookupGTWithDefault :: RecordId -> Map.Map RecordId RecordIdRange -> RecordIdRange
lookupGTWithDefault recordId ranges = maybe (RecordIdRange maxBound maxBound) snd $ Map.lookupGT recordId ranges

-- is r1 the successor of r2
isSuccessor :: RecordId -> RecordId -> Map.Map Word64 Word32 -> Bool
isSuccessor r1 r2 batchNumMap
  | r2 == minBound = False
  | r1 <= r2 = False
  | recordIdBatchId r1 == recordIdBatchId r2 = recordIdBatchIndex r1 == recordIdBatchIndex r2 + 1
  | recordIdBatchId r1 > recordIdBatchId r2 = isLastInBatch r2 batchNumMap && (recordIdBatchId r1 == recordIdBatchId r2 + 1) && (recordIdBatchIndex r1 == 0)

isPrecursor :: RecordId -> RecordId -> Map.Map Word64 Word32 -> Bool
isPrecursor r1 r2 batchNumMap
  | r2 == maxBound = False
  | otherwise = isSuccessor r2 r1 batchNumMap

isLastInBatch :: RecordId -> Map.Map Word64 Word32 -> Bool
isLastInBatch recordId batchNumMap =
  case Map.lookup (recordIdBatchId recordId) batchNumMap of
    Nothing  -> error "no recordIdBatchId found"
    Just num -> recordIdBatchIndex recordId == num - 1

getSuccessor :: RecordId -> Map.Map Word64 Word32 -> RecordId
getSuccessor r@RecordId{..} batchNumMap =
  if isLastInBatch r batchNumMap
  then RecordId (recordIdBatchId + 1) 0
  else r {recordIdBatchIndex = recordIdBatchIndex + 1}
--------------------------------------------------------------------------------

runTaskWrapper :: HS.StreamType -> HS.StreamType -> TaskBuilder -> HS.LDClient -> IO ()
runTaskWrapper sourceType sinkType taskBuilder ldclient = do
  -- create a new ckpReader from ldclient
  let readerName = textToCBytes (getTaskName taskBuilder)
  -- FIXME: We are not sure about the number of logs we are reading here, so currently the max number of log is set to 1000
  ldreader <- HS.newLDRsmCkpReader ldclient readerName HS.checkpointStoreLogID 5000 1000 Nothing 10
  -- create a new sourceConnector
  let sourceConnector = HCS.hstoreSourceConnector ldclient ldreader sourceType
  -- create a new sinkConnector
  let sinkConnector = HCS.hstoreSinkConnector ldclient sinkType
  -- RUN TASK
  runTask sourceConnector sinkConnector taskBuilder

runSinkConnector
  :: ServerContext
  -> CB.CBytes -- ^ Connector Id
  -> SourceConnectorWithoutCkp
  -> SinkConnector
  -> IO ThreadId
runSinkConnector ServerContext{..} cid src connector = do
    P.withMaybeZHandle zkHandle $ P.setConnectorStatus cid Running
    forkIO $ catches (forever action) cleanup
  where
    writeToConnector c SourceRecord{..} =
      writeRecord c $ SinkRecord srcStream srcKey srcValue srcTimestamp
    action = readRecordsWithoutCkp src >>= mapM_ (writeToConnector connector)
    cleanup =
      [ Handler (\(_ :: ERRException) -> do
                    Log.warning "Sink connector thread died due to SQL errors"
                    P.withMaybeZHandle zkHandle $ P.setConnectorStatus cid ConnectionAbort
                    void releasePid)
      , Handler (\(e :: AsyncException) -> do
                    Log.debug . Log.buildString $ "Sink connector thread killed because of " <> show e
                    P.withMaybeZHandle zkHandle $ P.setConnectorStatus cid Terminated
                    void releasePid)
      ]
    releasePid = do
      hmapC <- readMVar runningConnectors
      swapMVar runningConnectors $ HM.delete cid hmapC

handlePushQueryCanceled :: ServerCall () -> IO () -> IO ()
handlePushQueryCanceled ServerCall{..} handle = do
  x <- runOps unsafeSC callCQ [OpRecvCloseOnServer]
  case x of
    Left err   -> print err
    Right []   -> putStrLn "GRPCIOInternalUnexpectedRecv"
    Right [OpRecvCloseOnServerResult b]
      -> when b handle
    _ -> putStrLn "impossible happened"

eitherToResponse :: Either SomeException () -> a -> IO (ServerResponse 'Normal a)
eitherToResponse (Left err) _   =
  returnErrResp StatusInternal $ StatusDetails (C.pack . displayException $ err)
eitherToResponse (Right _) resp =
  returnResp resp

responseWithErrorMsgIfNothing :: Maybe a -> StatusCode -> StatusDetails -> IO (ServerResponse 'Normal a)
responseWithErrorMsgIfNothing (Just resp) _ _ = return $ ServerNormalResponse (Just resp) [] StatusOk ""
responseWithErrorMsgIfNothing Nothing errCode msg = return $ ServerNormalResponse Nothing [] errCode msg

convertSubscription :: Api.Subscription -> (T.Text, RecordId)
convertSubscription Api.Subscription{..} =
  let streamName = TL.toStrict subscriptionStreamName
      Api.SubscriptionOffset{..} = fromJust subscriptionOffset
      rid = case fromJust subscriptionOffsetOffset of
               Api.SubscriptionOffsetOffsetSpecialOffset _ -> error "shoud not reach here"
               Api.SubscriptionOffsetOffsetRecordOffset r  -> r
    in (streamName, rid)

--------------------------------------------------------------------------------
-- GRPC Handler Helper

handleCreateSinkConnector
  :: ServerContext
  -> CB.CBytes -- ^ Connector Name
  -> T.Text -- ^ Source Stream Name
  -> ConnectorConfig -> IO P.PersistentConnector
handleCreateSinkConnector serverCtx@ServerContext{..} cid sName cConfig = do
  onException action cleanup
  where
    cleanup = do
      Log.debug "Create sink connector failed"
      P.withMaybeZHandle zkHandle $ P.setConnectorStatus cid CreationAbort

    action = do
      P.withMaybeZHandle zkHandle $ P.setConnectorStatus cid Creating
      Log.debug "Start creating sink connector"
      ldreader <- HS.newLDReader scLDClient 1000 Nothing
      let src = HCS.hstoreSourceConnectorWithoutCkp scLDClient ldreader
      subscribeToStreamWithoutCkp src sName Latest

      connector <- case cConfig of
        ClickhouseConnector config  -> do
          Log.debug $ "Connecting to clickhouse with " <> Log.buildString (show config)
          clickHouseSinkConnector  <$> createClient config
        MySqlConnector table config -> do
          Log.debug $ "Connecting to mysql with " <> Log.buildString (show config)
          mysqlSinkConnector table <$> MySQL.connect config
      P.withMaybeZHandle zkHandle $ P.setConnectorStatus cid Created
      Log.debug . Log.buildString . CB.unpack $ cid <> "Connected"

      tid <- runSinkConnector serverCtx cid src connector
      Log.debug . Log.buildString $ "Sink connector started running on thread#" <> show tid

      takeMVar runningConnectors >>= putMVar runningConnectors . HM.insert cid tid
      P.withMaybeZHandle zkHandle $ P.getConnector cid

-- TODO: return info in a more maintainable way
handleCreateAsSelect :: ServerContext
                     -> TaskBuilder
                     -> TL.Text
                     -> P.QueryType
                     -> HS.StreamType
                     -> IO (CB.CBytes, Int64)
handleCreateAsSelect ServerContext{..} taskBuilder commandQueryStmtText queryType sinkType = do
  (qid, timestamp) <- P.createInsertPersistentQuery
    (getTaskName taskBuilder) (TL.toStrict commandQueryStmtText) queryType zkHandle
  P.withMaybeZHandle zkHandle (P.setQueryStatus qid Running)
  tid <- forkIO $ catches (action qid) (cleanup qid)
  takeMVar runningQueries >>= putMVar runningQueries . HM.insert qid tid
  return (qid, timestamp)
  where
    action qid = do
      Log.debug . Log.buildString
        $ "CREATE AS SELECT: query " <> show qid
       <> " has stared working on " <> show commandQueryStmtText
      runTaskWrapper HS.StreamTypeStream sinkType taskBuilder scLDClient
    cleanup qid =
      [ Handler (\(e :: AsyncException) -> do
                    Log.debug . Log.buildString
                       $ "CREATE AS SELECT: query " <> show qid
                      <> " is killed because of " <> show e
                    P.withMaybeZHandle zkHandle $ P.setQueryStatus qid Terminated
                    void $ releasePid qid)
      , Handler (\(e :: SomeException) -> do
                    Log.warning . Log.buildString
                       $ "CREATE AS SELECT: query " <> show qid
                      <> " died because of " <> show e
                    P.withMaybeZHandle zkHandle $ P.setQueryStatus qid ConnectionAbort
                    void $ releasePid qid)
      ]
    releasePid qid = do
      hmapC <- readMVar runningQueries
      swapMVar runningQueries $ HM.delete qid hmapC


handleTerminateConnector :: ServerContext -> CB.CBytes -> IO ()
handleTerminateConnector ServerContext{..} cid = do
  hmapC <- readMVar runningConnectors
  case HM.lookup cid hmapC of
    Just tid -> do
      void $ killThread tid
      Log.debug . Log.buildString $ "TERMINATE: terminated connector: " <> show cid
    _        -> throwIO ConnectorNotExist

dropHelper :: ServerContext -> T.Text -> Bool -> Bool
  -> IO (ServerResponse 'Normal Empty)
dropHelper sc@ServerContext{..} name checkIfExist isView = do
  when isView $ atomicModifyIORef' groupbyStores (\hm -> (HM.delete name hm, ()))
  let sName = if isView then HCS.transToViewStreamName name else HCS.transToStreamName name
  streamExists <- HS.doesStreamExists scLDClient sName
  if streamExists
    then terminateQueryAndRemove sc (textToCBytes name)
      >> terminateRelatedQueries sc (textToCBytes name)
      >> HS.removeStream scLDClient sName
      >> returnResp Empty
    else if checkIfExist
           then returnResp Empty
           else do
           Log.warning $ "Drop: tried to remove a nonexistent object: "
             <> Log.buildString (T.unpack name)
           returnErrResp StatusInternal "Object does not exist"

--------------------------------------------------------------------------------
-- Query

terminateQueryAndRemove :: ServerContext -> CB.CBytes -> IO ()
terminateQueryAndRemove sc@ServerContext{..} objectId = do
  queries <- P.withMaybeZHandle zkHandle P.getQueries
  let queryExists = find (\query -> P.getQuerySink query == objectId) queries
  case queryExists of
    Just query -> do
      Log.debug . Log.buildString
         $ "TERMINATE: found query " <> show (P.queryType query)
        <> " with query id " <> show (P.queryId query)
        <> " writes to the stream being dropped " <> show objectId
      void $ handleQueryTerminate sc (OneQuery $ P.queryId query)
      P.withMaybeZHandle zkHandle (P.removeQuery' $ P.queryId query)
      Log.debug . Log.buildString
         $ "TERMINATE: query " <> show (P.queryType query)
        <> " has been removed"
    Nothing    -> do
      Log.debug . Log.buildString
        $ "TERMINATE: found no query writes to the stream being dropped " <> show objectId

terminateRelatedQueries :: ServerContext -> CB.CBytes -> IO ()
terminateRelatedQueries sc@ServerContext{..} name = do
  queries <- P.withMaybeZHandle zkHandle P.getQueries
  let getRelatedQueries = [P.queryId query | query <- queries, name `elem` P.getRelatedStreams query]
  Log.debug . Log.buildString
     $ "TERMINATE: the queries related to the terminating stream " <> show name
    <> ": " <> show getRelatedQueries
  mapM_ (handleQueryTerminate sc . OneQuery) getRelatedQueries

handleQueryTerminate :: ServerContext -> TerminationSelection -> IO [CB.CBytes]
handleQueryTerminate ServerContext{..} (OneQuery qid) = do
  hmapQ <- readMVar runningQueries
  case HM.lookup qid hmapQ of Just tid -> killThread tid; _ -> pure ()
  P.withMaybeZHandle zkHandle $ P.setQueryStatus qid Terminated
  void $ swapMVar runningQueries (HM.delete qid hmapQ)
  Log.debug . Log.buildString $ "TERMINATE: terminated query: " <> show qid
  return [qid]
handleQueryTerminate sc@ServerContext{..} AllQueries = do
  hmapQ <- readMVar runningQueries
  handleQueryTerminate sc (ManyQueries $ HM.keys hmapQ)
handleQueryTerminate ServerContext{..} (ManyQueries qids) = do
  hmapQ <- readMVar runningQueries
  qids' <- foldrM (action hmapQ) [] qids
  Log.debug . Log.buildString $ "TERMINATE: terminated queries: " <> show qids'
  return qids'
  where
    action hm x terminatedQids = do
      result <- try $ do
        case HM.lookup x hm of
          Just tid -> killThread tid
          _        -> pure ()
      case result of
        Left (e ::SomeException) -> do
          Log.warning . Log.buildString
            $ "TERMINATE: unable to terminate query: " <> show x
           <> "because of " <> show e
          return terminatedQids
        Right _                  -> return (x:terminatedQids)
