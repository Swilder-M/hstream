module HStream.StoreSpec where

import           Test.Hspec
import qualified Z.Data.Builder          as B
import qualified Z.Data.CBytes           as CBytes
import           Z.Data.Vector           (packASCII)

import qualified HStream.Logger          as Log
import qualified HStream.Store           as S
import           HStream.Store.SpecUtils

spec :: Spec
spec = describe "StoreSpec" $ do
  base
  except

base :: Spec
base = describe "Base" $ do
  let logid = 1

  it "get tail sequence number" $ do
    seqNum0 <- S.appendCompLSN <$> S.append client logid "hello" Nothing
    seqNum1 <- S.getTailLSN client logid
    seqNum0 `shouldBe` seqNum1

  it "trim record" $ do
    sn0 <- S.appendCompLSN <$> S.append client logid "hello" Nothing
    sn1 <- S.appendCompLSN <$> S.append client logid "world" Nothing
    readPayload logid (Just sn0) `shouldReturn` "hello"
    S.trim client logid sn0
    readPayload' logid (Just sn0) `shouldReturn` []
    readPayload logid (Just sn1) `shouldReturn` "world"

  it "find time with a timestamp of 0" $ do
    headSn <- S.findTime client logid 0 S.FindKeyStrict
    S.trim client logid headSn
    sn <- S.findTime client logid 0 S.FindKeyStrict
    sn `shouldBe` headSn + 1

  -- FIXME: need to find correct way to test this
  --
  --it "find time with maximal timestamp" $ do
  --  sn0 <- S.appendCompLSN <$> S.append client logid "test" Nothing
  --  sn1 <- S.findTime client logid maxBound S.FindKeyStrict
  --  sn1 `shouldBe` sn0 + 1
  --  -- findTime(max) respects the trim point but there was an off-by-one in the
  --  -- code when the entire log was trimmed.
  --  S.trim client logid sn0
  --  sn2 <- S.findTime client logid maxBound S.FindKeyStrict
  --  sn2 `shouldBe` sn0 + 1

except :: Spec
except = describe "Except" $ do
  it "get tailLSN of an unknown logid should throw NOTFOUND" $ do
    -- Note: this do not fail immediately.
    let logid' = 10000 -- an unknown logid
    S.getTailLSN client logid' `shouldThrow` S.isNOTFOUND
