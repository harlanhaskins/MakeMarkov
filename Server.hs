{-# LANGUAGE DataKinds #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}

import Control.Applicative
import Control.Monad.IO.Class
import Data.Aeson
import Data.Proxy
import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.FromRow
import Database.PostgreSQL.Simple.ToField
import Database.PostgreSQL.Simple.ToRow
import GHC.Generics
import Network.Wai.Handler.Warp (run)
import Data.Char
import Data.List
import Data.String.Utils
import Servant
import MakeMarkov

data Character = Character
  { name    :: String
  , tagline :: String
  } deriving Generic

toPath = map toLower . replace " " "-"

-- JSON instances
instance FromJSON Character where
    parseJSON (Object v) = Character
                       <$> v .: "name"
                       <*> v .: "tagline"

instance ToJSON Character where
    toJSON (Character name tagline) = object
        [ "name"    .= name
        , "tagline" .= tagline
        , "path"    .= toPath name
        ]

-- PostgreSQL instances
instance FromRow Character where
  fromRow = Character <$> field <*> field

instance ToRow Character where
  toRow character = [ toField (name character)
                    , toField (tagline character)
                    ]

type CharacterAPI = "characters" :> ReqBody Character :> Post Character
               :<|> "characters" :> Get [Character]
               :<|> "quotes" :> Capture "character" String :> QueryParam "count" Int :> Get [String]

server :: Connection -> Server CharacterAPI
server conn = postCharacter
         :<|> getCharacters
         :<|> getQuotes
    where postCharacter character          = liftIO $ execute conn "insert into characters values (?, ?)" character >> return character
          getCharacters                    = liftIO $ query_ conn "select * from characters"
          getQuotes character Nothing      = getQuotes character (Just 1)
          getQuotes character (Just count) = liftIO $ newMarkov count ["Hello!"]

characterAPI :: Proxy CharacterAPI
characterAPI = Proxy

main = connectPostgreSQL "host=localhost user=harlanhaskins dbname=markov"
           >>= run 8080
             . serve characterAPI
             . server

