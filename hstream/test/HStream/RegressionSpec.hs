{-# LANGUAGE GADTs               #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE PatternSynonyms     #-}
{-# LANGUAGE RecordWildCards     #-}
{-# LANGUAGE ScopedTypeVariables #-}

module HStream.RegressionSpec (spec) where

import           Control.Concurrent
import qualified Data.Aeson           as Aeson
import           Test.Hspec

import           HStream.SpecUtils
import           HStream.Store.Logger (pattern C_DBG_ERROR,
                                       setLogDeviceDbgLevel)
import           HStream.Utils        (setupSigsegvHandler)

spec :: Spec
spec = aroundAll provideHstreamApi $
  describe "HStream.RegressionSpec" $ do
  runIO setupSigsegvHandler
  runIO $ setLogDeviceDbgLevel C_DBG_ERROR

  it "#391_JOIN" $ \api -> do
    runCreateStreamSql api "CREATE STREAM s1;"
    runCreateStreamSql api "CREATE STREAM s2;"
    _ <- forkIO $ do
      threadDelay 5000000 -- FIXME: requires a notification mechanism to ensure that the task starts successfully before inserting data
      runInsertSql api "INSERT INTO s1 (a, b) VALUES (1, 3);"
      runInsertSql api "INSERT INTO s2 (a, b) VALUES (2, 3);"
    executeCommandPushQuery "SELECT s1.a, s2.a, s1.b, s2.b, SUM(s1.a), SUM(s2.a) FROM s1 INNER JOIN s2 WITHIN (INTERVAL 1 MINUTE) ON (s1.b = s2.b) GROUP BY s1.b EMIT CHANGES;"
      `shouldReturn` [ mkStruct
        [ ("SUM(s1.a)", Aeson.Number 1)
        , ("SUM(s2.a)", Aeson.Number 2)
        , ("s1.a"     , Aeson.Number 1)
        , ("s1.b"     , Aeson.Number 3)
        , ("s2.a"     , Aeson.Number 2)
        , ("s2.b"     , Aeson.Number 3)]]
    runDropSql api "DROP STREAM s1 IF EXISTS;"
    runDropSql api "DROP STREAM s2 IF EXISTS;"

  it "#394_SESSION" $ \api -> do
    runCreateStreamSql api "CREATE STREAM s3;"
    _ <- forkIO $ do
      threadDelay 5000000 -- FIXME: requires a notification mechanism to ensure that the task starts successfully before inserting data
      runInsertSql api "INSERT INTO s3 (a, b) VALUES (1, 4);"
      runInsertSql api "INSERT INTO s3 (a, b) VALUES (1, 4);"
      runInsertSql api "INSERT INTO s3 (a, b) VALUES (1, 4);"
      runInsertSql api "INSERT INTO s3 (a, b) VALUES (1, 4);"
    executeCommandPushQuery "SELECT a, b, SUM(a) FROM s3 GROUP BY b, SESSION(INTERVAL 10 MINUTE) EMIT CHANGES;"
      `shouldReturn`
      [ mkStruct [("SUM(a)", Aeson.Number 1), ("a", Aeson.Number 1), ("b", Aeson.Number 4)]
      , mkStruct [("SUM(a)", Aeson.Number 2), ("a", Aeson.Number 1), ("b", Aeson.Number 4)]
      , mkStruct [("SUM(a)", Aeson.Number 3), ("a", Aeson.Number 1), ("b", Aeson.Number 4)]
      , mkStruct [("SUM(a)", Aeson.Number 4), ("a", Aeson.Number 1), ("b", Aeson.Number 4)] ]
    runDropSql api "DROP STREAM s3 IF EXISTS;"

  it "#403_RAW" $ \api -> do
    runCreateStreamSql api "CREATE STREAM s4;"
    runCreateWithSelectSql api "CREATE STREAM s5 AS SELECT SUM(a), a + 1, COUNT(*) AS result, b FROM s4 GROUP BY b EMIT CHANGES;"
    _ <- forkIO $ do
      threadDelay 5000000 -- FIXME: requires a notification mechanism to ensure that the task starts successfully before inserting data
      runInsertSql api "INSERT INTO s4 (a, b) VALUES (1, 4);"
      runInsertSql api "INSERT INTO s4 (a, b) VALUES (1, 4);"
      runInsertSql api "INSERT INTO s4 (a, b) VALUES (1, 4);"
      runInsertSql api "INSERT INTO s4 (a, b) VALUES (1, 4);"
    executeCommandPushQuery "SELECT `SUM(a)`, `result` AS cnt, b, `a+1` FROM s5 EMIT CHANGES;"
      `shouldReturn`
      [ mkStruct [("cnt", Aeson.Number 1), ("a+1", Aeson.Number 2), ("b", Aeson.Number 4), ("SUM(a)", Aeson.Number 1)]
      , mkStruct [("cnt", Aeson.Number 2), ("a+1", Aeson.Number 2), ("b", Aeson.Number 4), ("SUM(a)", Aeson.Number 2)]
      , mkStruct [("cnt", Aeson.Number 3), ("a+1", Aeson.Number 2), ("b", Aeson.Number 4), ("SUM(a)", Aeson.Number 3)]
      , mkStruct [("cnt", Aeson.Number 4), ("a+1", Aeson.Number 2), ("b", Aeson.Number 4), ("SUM(a)", Aeson.Number 4)]]
    runDropSql api "DROP STREAM s4 IF EXISTS;"
    runDropSql api "DROP STREAM s5 IF EXISTS;"

  it "HS352_INT" $ \api -> do
    runCreateStreamSql api "CREATE STREAM s6;"
    runQuerySimple_ api "CREATE VIEW v6 as SELECT key1, key2, key3, SUM(key1) FROM s6 GROUP BY key1 EMIT CHANGES;"
    _ <- forkIO $ do
      threadDelay 2000000 -- FIXME: requires a notification mechanism to ensure that the task starts successfully before inserting data
      runInsertSql api "INSERT INTO s6 (key1, key2, key3) VALUES (0, \"hello_00000000000000000000\", true);"
      runInsertSql api "INSERT INTO s6 (key1, key2, key3) VALUES (1, \"hello_00000000000000000001\", false);"
      runInsertSql api "INSERT INTO s6 (key1, key2, key3) VALUES (0, \"hello_00000000000000000002\", true);"
      runInsertSql api "INSERT INTO s6 (key1, key2, key3) VALUES (1, \"hello_00000000000000000003\", false);"
      runInsertSql api "INSERT INTO s6 (key1, key2, key3) VALUES (0, \"hello_00000000000000000004\", true);"
    threadDelay 4000000
    runQuerySimple api "SELECT * FROM v6 WHERE key1 = 1;"
      `grpcShouldReturn` mkViewResponse (mkStruct [ ("SUM(key1)", Aeson.Number 2)
                                                  , ("key1", Aeson.Number 1)
                                                  , ("key2", Aeson.String "hello_00000000000000000003")
                                                  , ("key3", Aeson.Bool False)]
                                        )
    runDropSql api "DROP STREAM s6 IF EXISTS;"
    runDropSql api "DROP VIEW v6 IF EXISTS;"
