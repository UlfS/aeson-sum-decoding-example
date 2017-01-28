{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}

module Lib
    ( lib
    ) where

import           GHC.Generics

import           Control.Monad

import           Data.Aeson
import           Data.Aeson.Types
import           Data.ByteString.Lazy       (ByteString)
import qualified Data.ByteString.Lazy.Char8 as BL
import           Data.Char
import           Data.Maybe
import           Data.Text                  (Text)


data Test
  = A { tstVal :: Text }
  | B { tstVal :: Text }
  deriving (Show, Generic)

instance FromJSON Test where
  parseJSON = genericParseJSON jsonParseOpts


jsonParseOpts :: Options
jsonParseOpts = defaultOptions
  { fieldLabelModifier = labelModifier
  , sumEncoding = ObjectWithSingleField -- "injection" strategy
  }
  where
  labelModifier name = let (x:xs) = drop 3 name in switchCase x : xs
  switchCase a = if isUpper a then toLower a else toUpper a


-- "injecting" the constructor tag by wrapping it in a field named after the
-- constructor, see `ObjectWithSingleField`.
injectConstructor :: Text -> Value -> Value
injectConstructor h o = object [h .= o]

parseJSON' :: FromJSON a => Text -> Value -> Maybe a
parseJSON' c = parseMaybe $ parseJSON . injectConstructor c

parse' :: FromJSON a => Text -> ByteString -> Maybe a
parse' c t = decode t >>= parseJSON' c


lib :: IO ()
lib = do
  let json =
        [ "{ \"A\": { \"val\" : \"test\" } }"
        , "{ \"B\": { \"val\" : \"test\" } }"
        , "{ \"val\" : \"test\" }"]
  forM_ json $ \j -> do
    putStrLn ""

    putStr "RAW: "
    BL.putStrLn j

    putStr "DEC: "
    print (decode j :: Maybe Test)


    let value = fromJust $ decode j :: Value
    putStr "INJ: "
    print (parseJSON' "A" value :: Maybe Test)
    putStr "     "
    print (parseJSON' "B" value :: Maybe Test)
