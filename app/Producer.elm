module Producer exposing (..)

import Dict
import Json.Encode as JSE
import Utils.List as ListOps


type alias State =
    List Producer


type alias Producer =
    { name : String
    , production : Int
    , price : Int
    , boughtCount : Int
    }


type alias SerializedProducer =
    { name : String
    , boughtCount : Int
    }


canBeBought : Producer -> Int -> Bool
canBeBought producer cookies =
    producer.price <= cookies


buy : Producer -> State -> State
buy producer producers =
    ListOps.overMatching (nameEquals producer) (increaseBoughtCount) producers


sumProduction : State -> Int
sumProduction producers =
    producers
        |> List.map (currentProduction)
        |> List.foldl (+) 0


currentProduction : Producer -> Int
currentProduction producer =
    producer.boughtCount * producer.production


applyCounts : List Producer -> List SerializedProducer -> List Producer
applyCounts producers serializedProducers =
    let
        countsDict =
            List.foldl (\producer dict -> Dict.insert producer.name producer.boughtCount dict) Dict.empty serializedProducers
    in
        List.map (\producer -> { producer | boughtCount = Dict.get producer.name countsDict |> Maybe.withDefault producer.boughtCount }) producers


serialize : Producer -> JSE.Value
serialize producer =
    JSE.object
        [ ( "name", JSE.string producer.name )
        , ( "boughtCount", JSE.int producer.boughtCount )
        ]


nameEquals : Producer -> Producer -> Bool
nameEquals p1 p2 =
    p1.name == p2.name


increaseBoughtCount : Producer -> Producer
increaseBoughtCount producer =
    { producer | boughtCount = producer.boughtCount + 1 }
