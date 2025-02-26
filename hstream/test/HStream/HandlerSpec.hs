{-# LANGUAGE GADTs               #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE PatternSynonyms     #-}
{-# LANGUAGE RecordWildCards     #-}
{-# LANGUAGE ScopedTypeVariables #-}

module HStream.HandlerSpec (spec) where

import           Control.Monad                    (forM_, replicateM, void)
import qualified Data.ByteString                  as B
import qualified Data.Map.Strict                  as Map
import           Data.Maybe                       (fromJust)
import qualified Data.Set                         as Set
import qualified Data.Text.Lazy                   as TL
import qualified Data.Vector                      as V
import           Data.Word                        (Word32, Word64)
import           Network.GRPC.HighLevel.Generated
import           Proto3.Suite                     (Enumerated (..))
import           Proto3.Suite.Class               (HasDefault (def))
import           Test.Hspec
import           Z.Foreign                        (toByteString)

import qualified HStream.Logger                   as Log
import           HStream.Server.HStreamApi
import           HStream.SpecUtils
import           HStream.Store.Logger             (pattern C_DBG_ERROR,
                                                   setLogDeviceDbgLevel)
import qualified HStream.ThirdParty.Protobuf      as PB
import           HStream.Utils

spec :: Spec
spec =  describe "HStream.HandlerSpec" $ do
  runIO setupSigsegvHandler
  runIO $ setLogDeviceDbgLevel C_DBG_ERROR

  streamSpec
  subscribeSpec
  consumerSpec

----------------------------------------------------------------------------------------------------------
-- StreamSpec

withRandomStreamName :: ActionWith (HStreamClientApi, TL.Text) -> HStreamClientApi -> IO ()
withRandomStreamName = provideRunTest setup clean
  where
    setup _api = ("StreamSpec_" <>) . TL.fromStrict <$> newRandomText 20
    clean api name = deleteStreamRequest_ api name `shouldReturn` PB.Empty

withRandomStreamNames :: ActionWith (HStreamClientApi, [TL.Text]) -> HStreamClientApi -> IO ()
withRandomStreamNames = provideRunTest setup clean
  where
    setup _api = replicateM 5 $ TL.fromStrict <$> newRandomText 20
    clean api names = forM_ names $ \name -> do
      deleteStreamRequest_ api name `shouldReturn` PB.Empty

streamSpec :: Spec
streamSpec = aroundAll provideHstreamApi $ describe "StreamSpec" $ parallel $ do

  aroundWith withRandomStreamName $ do
    it "test createStream request" $ \(api, name) -> do
      let stream = Stream name 3
      createStreamRequest api stream `shouldReturn` stream
      -- create an existed stream should fail
      createStreamRequest api stream `shouldThrow` anyException

  aroundWith withRandomStreamNames $ do
    it "test listStream request" $ \(api, names) -> do
      let createStreamReqs = zipWith Stream names [1, 2, 3, 3, 2]
      forM_ createStreamReqs $ \stream -> do
        createStreamRequest api stream `shouldReturn` stream

      resp <- listStreamRequest api
      let sortedResp = Set.fromList $ V.toList resp
          sortedReqs = Set.fromList createStreamReqs
      sortedReqs `shouldSatisfy` (`Set.isSubsetOf` sortedResp)

  aroundWith withRandomStreamName $ do
    it "test deleteStream request" $ \(api, name) -> do
      let stream = Stream name 1
      createStreamRequest api stream `shouldReturn` stream
      resp <- listStreamRequest api
      resp `shouldSatisfy` V.elem stream
      deleteStreamRequest api name `shouldReturn` PB.Empty
      resp' <- listStreamRequest api
      resp' `shouldNotSatisfy`  V.elem stream
      -- delete a nonexistent stream without ignoreNonExist set should throw an exception
      deleteStreamRequest api name `shouldThrow` anyException
      -- delete a nonexistent stream with ignoreNonExist set should be okay
      deleteStreamRequest_ api name `shouldReturn` PB.Empty

  aroundWith withRandomStreamName $ do
    it "test append request" $ \(api, name) -> do
      payload1 <- newRandomByteString 5
      payload2 <- newRandomByteString 5
      timeStamp <- getProtoTimestamp
      let stream = Stream name 1
          header = buildRecordHeader HStreamRecordHeader_FlagRAW Map.empty timeStamp TL.empty
          record1 = buildRecord header payload1
          record2 = buildRecord header payload2
      -- append to a nonexistent stream should throw exception
      appendRequest api name (V.fromList [record1, record2]) `shouldThrow` anyException
      createStreamRequest api stream `shouldReturn` stream
      resp <- appendRequest api name (V.fromList [record1, record2])
      appendResponseStreamName resp `shouldBe` name
      recordIdBatchIndex <$> appendResponseRecordIds resp `shouldBe` V.fromList [0, 1]

-------------------------------------------------------------------------------------------------

createStreamRequest :: HStreamClientApi -> Stream -> IO Stream
createStreamRequest HStreamApi{..} stream =
  let req = ClientNormalRequest stream requestTimeout $ MetadataMap Map.empty
  in getServerResp =<< hstreamApiCreateStream req

listStreamRequest :: HStreamClientApi -> IO (V.Vector Stream)
listStreamRequest HStreamApi{..} =
  let req = ClientNormalRequest ListStreamsRequest requestTimeout $ MetadataMap Map.empty
  in listStreamsResponseStreams <$> (getServerResp =<< hstreamApiListStreams req)

deleteStreamRequest :: HStreamClientApi -> TL.Text -> IO PB.Empty
deleteStreamRequest HStreamApi{..} streamName =
  let delReq = def { deleteStreamRequestStreamName = streamName }
      req = ClientNormalRequest delReq requestTimeout $ MetadataMap Map.empty
  in getServerResp =<< hstreamApiDeleteStream req

-- This request is mainly used for cleaning up after testing
deleteStreamRequest_ :: HStreamClientApi -> TL.Text -> IO PB.Empty
deleteStreamRequest_ HStreamApi{..} streamName =
  let delReq = def { deleteStreamRequestStreamName = streamName
                   , deleteStreamRequestIgnoreNonExist = True }
      req = ClientNormalRequest delReq requestTimeout $ MetadataMap Map.empty
  in getServerResp =<< hstreamApiDeleteStream req

appendRequest :: HStreamClientApi -> TL.Text -> V.Vector HStreamRecord -> IO AppendResponse
appendRequest HStreamApi{..} streamName records =
  let appReq = AppendRequest streamName records
      req = ClientNormalRequest appReq requestTimeout $ MetadataMap Map.empty
  in getServerResp =<< hstreamApiAppend req

----------------------------------------------------------------------------------------------------------
-- SubscribeSpec

withSubscription :: ActionWith (HStreamClientApi, (TL.Text, TL.Text)) -> HStreamClientApi -> IO ()
withSubscription = provideRunTest setup clean
  where
    setup _api = do
      stream <- TL.fromStrict <$> newRandomText 5
      subscription <- TL.fromStrict <$> newRandomText 5
      return ("StreamSpec_" <> stream, "SubscriptionSpec_" <> subscription)
    clean api (streamName, subscriptionName) = do
      deleteSubscriptionRequest api subscriptionName `shouldReturn` True
      deleteStreamRequest_ api streamName `shouldReturn` PB.Empty

withSubscriptions :: ActionWith (HStreamClientApi, (V.Vector TL.Text, V.Vector TL.Text))
                  -> HStreamClientApi -> IO ()
withSubscriptions = provideRunTest setup clean
  where
    setup _api = do
      stream <- V.replicateM 5 $ TL.fromStrict <$> newRandomText 5
      subscription <- V.replicateM 5 $ TL.fromStrict <$> newRandomText 5
      return (("StreamSpec_" <>) <$> stream, ("SubscriptionSpec_" <>) <$> subscription)
    clean api (streamNames, subscriptionNames) = do
      forM_ streamNames $ \name -> do
        deleteStreamRequest_ api name `shouldReturn` PB.Empty
      forM_ subscriptionNames $ \name -> do
        deleteSubscriptionRequest api name `shouldReturn` True

subscribeSpec :: Spec
subscribeSpec = aroundAll provideHstreamApi $
  describe "SubscribeSpec" $ parallel $ do

  let offset = SubscriptionOffset . Just . SubscriptionOffsetOffsetSpecialOffset
               . Enumerated . Right $ SubscriptionOffset_SpecialOffsetLATEST

  aroundWith withSubscription $ do
    it "test createSubscribe request" $ \(api, (streamName, subscriptionName)) -> do
      -- createSubscribe with a nonexistent stream should throw an exception
      createSubscriptionRequest api subscriptionName streamName offset `shouldThrow` anyException
      let stream = Stream streamName 1
      createStreamRequest api stream `shouldReturn` stream
      -- createSubscribe with an existing stream should return True
      createSubscriptionRequest api subscriptionName streamName offset `shouldReturn` True
      -- createSubscribe fails if the subscriptionName has been used
      createSubscriptionRequest api subscriptionName streamName offset `shouldThrow` anyException

  aroundWith withSubscription $ do
    it "test subscribe request" $ \(api, (streamName, subscriptionName)) -> do
      let stream = Stream streamName 1
      let subscriptionName' = subscriptionName <> "___"
      createStreamRequest api stream `shouldReturn` stream
      createSubscriptionRequest api subscriptionName streamName offset `shouldReturn` True
      -- subscribe a nonexistent subscriptionId should throw exception
      subscribeRequest api subscriptionName' `shouldThrow` anyException
      -- subscribe an existing subscriptionId should return True
      subscribeRequest api subscriptionName `shouldReturn` True
      -- re-subscribe is okay
      subscribeRequest api subscriptionName `shouldReturn` True
      -- subscribe is okay even though the stream has been deleted
      deleteStreamRequest api streamName `shouldReturn` PB.Empty
      subscribeRequest api subscriptionName `shouldReturn` True

  aroundWith withSubscriptions $ do
    it "test listSubscription request" $ \(api, (streamNames, subscriptionNames)) -> do
      let subscriptions = V.zipWith3 Subscription  subscriptionNames streamNames  $ V.replicate 5 (Just offset)
      forM_ subscriptions $ \Subscription{..} -> do
        let stream = Stream subscriptionStreamName 1
        createStreamRequest api stream `shouldReturn` stream
        createSubscriptionRequest api subscriptionSubscriptionId subscriptionStreamName
          (fromJust subscriptionOffset) `shouldReturn` True
        subscribeRequest api subscriptionSubscriptionId `shouldReturn` True
      resp <- listSubscriptionRequest api
      let respSet = Set.fromList $ subscriptionSubscriptionId <$> V.toList resp
          reqsSet = Set.fromList $ subscriptionSubscriptionId <$> V.toList subscriptions
      reqsSet `shouldSatisfy` (`Set.isSubsetOf` respSet)

  aroundWith withSubscription $ do
    it "test deleteSubscription request" $ \(api, (streamName, subscriptionName)) -> do
      let stream = Stream streamName 1
      createStreamRequest api stream `shouldReturn` stream
      createSubscriptionRequest api subscriptionName streamName offset `shouldReturn` True
      subscribeRequest api subscriptionName `shouldReturn` True
      -- delete a subscribed stream should return true
      deleteSubscriptionRequest api subscriptionName `shouldReturn` True
      -- double deletion is okay
      deleteSubscriptionRequest api subscriptionName `shouldReturn` True

  aroundWith withSubscription $ do
    it "deleteSubscription request with removed stream should success" $ \(api, (streamName, subscriptionName)) -> do
      let stream = Stream streamName 1
      createStreamRequest api stream `shouldReturn` stream
      createSubscriptionRequest api subscriptionName streamName offset `shouldReturn` True
      subscribeRequest api subscriptionName `shouldReturn` True
      -- delete a subscription with underlying stream deleted should success
      deleteStreamRequest api streamName `shouldReturn` PB.Empty
      deleteSubscriptionRequest api subscriptionName `shouldReturn` True

  aroundWith withSubscription $ do
    it "test hasSubscription request" $ \(api, (streamName, subscriptionName)) -> do
      void $ createStreamRequest api $ Stream streamName 1
      -- check a nonexistent subscriptionId should return False
      checkSubscriptionExistRequest api subscriptionName `shouldReturn` False
      -- check an existing subscriptionId should return True
      createSubscriptionRequest api subscriptionName streamName offset `shouldReturn` True
      checkSubscriptionExistRequest api subscriptionName `shouldReturn` True

----------------------------------------------------------------------------------------------------------

createSubscriptionRequest :: HStreamClientApi -> TL.Text -> TL.Text -> SubscriptionOffset -> IO Bool
createSubscriptionRequest HStreamApi{..} subscriptionId streamName offset =
  let subscription = Subscription subscriptionId streamName $ Just offset
      req = ClientNormalRequest subscription requestTimeout $ MetadataMap Map.empty
  in True <$ (getServerResp =<< hstreamApiCreateSubscription req)

subscribeRequest :: HStreamClientApi -> TL.Text -> IO Bool
subscribeRequest HStreamApi{..} subscribeId =
  let subReq = SubscribeRequest subscribeId
      req = ClientNormalRequest subReq requestTimeout $ MetadataMap Map.empty
  in True <$ (getServerResp =<< hstreamApiSubscribe req)

listSubscriptionRequest :: HStreamClientApi -> IO (V.Vector Subscription)
listSubscriptionRequest HStreamApi{..} =
  let req = ClientNormalRequest ListSubscriptionsRequest requestTimeout $ MetadataMap Map.empty
  in listSubscriptionsResponseSubscription <$> (getServerResp =<< hstreamApiListSubscriptions req)

deleteSubscriptionRequest :: HStreamClientApi -> TL.Text -> IO Bool
deleteSubscriptionRequest HStreamApi{..} subscribeId =
  let delReq = DeleteSubscriptionRequest subscribeId
      req = ClientNormalRequest delReq requestTimeout $ MetadataMap Map.empty
  in True <$ (getServerResp =<< hstreamApiDeleteSubscription req)

checkSubscriptionExistRequest :: HStreamClientApi -> TL.Text -> IO Bool
checkSubscriptionExistRequest HStreamApi{..} subscribeId =
  let checkReq = CheckSubscriptionExistRequest subscribeId
      req = ClientNormalRequest checkReq requestTimeout $ MetadataMap Map.empty
  in checkSubscriptionExistResponseExists <$> (getServerResp =<< hstreamApiCheckSubscriptionExist req)

----------------------------------------------------------------------------------------------------------
-- ConsumerSpec

withConsumerSpecEnv :: ActionWith (HStreamClientApi, (V.Vector B.ByteString, TL.Text, TL.Text))
                    -> HStreamClientApi -> IO ()
withConsumerSpecEnv = provideRunTest setup clean
  where
    setup api = do
      streamName <-  ("ConsumerSpec_" <>) . TL.fromStrict <$> newRandomText 20
      subName <- ("ConsumerSpec_" <>) . TL.fromStrict <$> newRandomText 20

      let offset = SubscriptionOffset . Just . SubscriptionOffsetOffsetSpecialOffset
                   . Enumerated . Right $ SubscriptionOffset_SpecialOffsetLATEST
      let stream = Stream streamName 1
      createStreamRequest api stream `shouldReturn` stream
      createSubscriptionRequest api subName streamName offset `shouldReturn` True
      subscribeRequest api subName `shouldReturn` True
      timeStamp <- getProtoTimestamp
      let header = buildRecordHeader HStreamRecordHeader_FlagRAW Map.empty timeStamp TL.empty
      payloads <- V.replicateM 5 $ do
        payload <- newRandomByteString 2
        let record = buildRecord header payload
        void $ appendRequest api streamName $ V.singleton record
        return payload
      return (payloads, streamName, subName)

    clean api (_payloads, streamName, subName) = do
      deleteSubscriptionRequest api subName `shouldReturn` True
      deleteStreamRequest_ api streamName `shouldReturn` PB.Empty

consumerSpec :: Spec
consumerSpec = aroundAll provideHstreamApi $ describe "ConsumerSpec" $ do

  aroundWith withConsumerSpecEnv $ do
    -- FIXME:
    it "test fetch request" $ \(api, (reqPayloads, _streamName, subName)) -> do
      Log.debug $ Log.buildString "reqPayloads = " <> Log.buildString (show reqPayloads)
      resp <- fetchRequest api subName (fromIntegral requestTimeout) 100
      let respPayloads = V.map getReceivedRecordPayload resp
      Log.debug $ Log.buildString "respPayload = " <> Log.buildString (show respPayloads)
      respPayloads `shouldBe` reqPayloads

----------------------------------------------------------------------------------------------------------

fetchRequest :: HStreamClientApi -> TL.Text -> Word64 -> Word32 -> IO (V.Vector ReceivedRecord)
fetchRequest HStreamApi{..} subscribeId timeout maxSize =
  let fetReq = FetchRequest subscribeId timeout maxSize
      req = ClientNormalRequest fetReq requestTimeout $ MetadataMap Map.empty
  in fetchResponseReceivedRecords <$> (getServerResp =<< hstreamApiFetch req)

requestTimeout :: Int
requestTimeout = 10

getReceivedRecordPayload :: ReceivedRecord -> B.ByteString
getReceivedRecordPayload ReceivedRecord{..} =
  toByteString . getPayload . decodeByteStringRecord $ receivedRecordRecord
