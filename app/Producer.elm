module Producer exposing (..)

import Dict
import Json.Encode as JSE


type Action = BuyProducer Producer

type alias State = List Producer

type alias Producer =
    { name: String
    , production: Int
    , price: Int
    , boughtCount: Int
    }

type alias SerializedProducer =
    { name: String
    , boughtCount : Int
    }

canBeBought : Producer -> Int -> Bool
canBeBought producer cookies =
    producer.price <= cookies

buy : Producer -> State -> State
buy producer producers =
    List.map
        (\p ->
            if p.name /= producer.name
            then p
            else { p | boughtCount = p.boughtCount + 1} )
        producers

produce : State -> Int
produce producers =
    producers
        |> List.filter (\producer -> producer.boughtCount > 0)
        |> List.map (currentProduction)
        |> List.foldl (+) 0

currentProduction : Producer -> Int
currentProduction producer =
    producer.boughtCount * producer.production

applyCounts : List Producer -> List SerializedProducer -> List Producer
applyCounts producers serializedProducers =
    let
        countsDict = List.foldl (\producer dict -> Dict.insert producer.name producer.boughtCount dict) Dict.empty serializedProducers
    in
        List.map (\producer -> { producer | boughtCount = Dict.get producer.name countsDict |> Maybe.withDefault producer.boughtCount }) producers

serialize : Producer -> JSE.Value
serialize producer =
    JSE.object
        [ ("name", JSE.string producer.name)
        , ("boughtCount", JSE.int producer.boughtCount)
        ]
