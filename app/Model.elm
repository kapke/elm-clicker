module Model exposing (..)

import Http
import Json.Decode as JSD
import Json.Encode as JSE
import Task
import Time exposing (Time)
import Cookie
import Notifications
import Producer exposing (Producer, SerializedProducer)
import User exposing (UserId, getUserId)


type alias DataWithUser =
    { cookies : Int
    , producers : List Producer
    , userId : UserId
    , notifications : Notifications.State
    }


type alias DataWithoutUser =
    { notifications : Notifications.State }


type Model
    = WithoutUser DataWithoutUser
    | WithUser DataWithUser


type alias SerializedModel =
    { cookies : Int
    , producers : List SerializedProducer
    }


producers =
    [ Producer "Grandma" 1 10 0
    , Producer "Bakery" 5 500 0
    , Producer "Factory" 20 1000 0
    , Producer "Mine" 50 5000 0
    ]


getNotifications : Model -> Notifications.State
getNotifications model =
    case model of
        WithUser r ->
            r.notifications

        WithoutUser r ->
            r.notifications


emptyDataWithUser : UserId -> Model -> DataWithUser
emptyDataWithUser userId model =
    { cookies = 0
    , producers = producers
    , userId = userId
    , notifications = getNotifications model
    }


tryBuyProducer : Producer -> DataWithUser -> DataWithUser
tryBuyProducer producer model =
    if Producer.canBeBought producer model.cookies then
        { model
            | cookies = Cookie.subtract producer.price model.cookies
            , producers = Producer.buy producer model.producers
        }
    else
        model


overCookies : (Int -> Int) -> DataWithUser -> DataWithUser
overCookies mapper model =
    { model | cookies = mapper model.cookies }


restore : UserId -> SerializedModel -> DataWithoutUser -> Model
restore userId serialized record =
    WithUser
        { userId = userId
        , cookies = serialized.cookies
        , producers = Producer.applyCounts producers serialized.producers
        , notifications = record.notifications
        }


serialize : Model -> JSE.Value
serialize model =
    let
        serializedJSE cookies producers =
            JSE.object
                [ ( "cookies", JSE.int cookies )
                , ( "producers", JSE.list (List.map Producer.serialize producers) )
                ]
    in
        case model of
            WithUser r ->
                serializedJSE r.cookies r.producers

            WithoutUser r ->
                serializedJSE 0 []


stateJsonDecoder : JSD.Decoder SerializedModel
stateJsonDecoder =
    let
        cookiesDecoder =
            JSD.field "cookies" JSD.int

        producerDecoder =
            JSD.map2
                SerializedProducer
                (JSD.field "name" JSD.string)
                (JSD.field "boughtCount" JSD.int)
    in
        JSD.map2
            SerializedModel
            cookiesDecoder
            (JSD.field "producers" (JSD.list producerDecoder))
