module Model exposing (..)

import Http
import Json.Decode as JSD
import Json.Encode as JSE
import Task
import Time exposing (Time)

import Cookie
import Notification exposing (Notification)
import Producer exposing (Producer, SerializedProducer)
import User exposing (getUserId)


type alias Model =
    { cookies : Int
    , producers : List Producer
    , userId : String
    , notifications : List Notification
    }

type alias SerializedModel =
    { cookies : Int
    , producers : List SerializedProducer
    }


type Msg =
    MakeCookie
    | BuyProducer Producer
    | ProduceCookies Time
    | SetUserId String
    | AddNotification Notification
    | RemoveNotification Notification
    | SaveState Time
    | StateSaved (Result Http.Error String)
    | RestoreState SerializedModel

serialize : Model -> JSE.Value
serialize model =
    JSE.object
        [ ("cookies", JSE.int model.cookies)
        , ("producers", JSE.list (List.map Producer.serialize model.producers))
        ]

stateJsonDecoder : JSD.Decoder SerializedModel
stateJsonDecoder =
    let
        cookiesDecoder = JSD.field "cookies" JSD.int
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

httpErrorToString : Http.Error -> String
httpErrorToString err = "Something went wrong with making request to game server. Check internet connection"

restoreState : String -> Cmd Msg
restoreState userId =
    let
        url = "https://clicker-e237b.firebaseio.com/game-statuses/" ++ userId ++ ".json"
    in
        Task.attempt
            (\result ->
                case result of
                    Result.Ok data -> RestoreState data
                    Result.Err err -> AddNotification (Notification ("Something went wrong" ++ err) 42))
            (Http.get url stateJsonDecoder
                |> Http.toTask
                |> Task.mapError httpErrorToString)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        MakeCookie ->
            ({ model | cookies = Cookie.add 1 model.cookies }, Cmd.none)
        BuyProducer producer ->
            if Producer.canBeBought producer model.cookies
            then
                (
                    { model
                    | cookies = Cookie.subtract producer.price model.cookies
                    , producers = Producer.buy producer model.producers
                    }
                , Cmd.none
                )
            else (model, Cmd.none)
        ProduceCookies time ->
            ({ model | cookies = Cookie.add model.cookies (Producer.produce model.producers)}, Cmd.none)

        SetUserId userId ->
            ( { model | userId = userId }
            , Cmd.batch
                [ Notification.add AddNotification ("User ID is set to " ++ userId)
                , restoreState userId
                ]
            )

        AddNotification notification ->
            ( { model | notifications = model.notifications |> List.reverse |> (::) notification }
            , Notification.remove RemoveNotification notification
            )
        RemoveNotification notification ->
            ( { model | notifications = List.filter (\n -> n.id /= notification.id) model.notifications}
            , Cmd.none
            )

        SaveState time ->
            let
                userId = model.userId
                url = "https://clicker-e237b.firebaseio.com/game-statuses/" ++ userId ++ ".json?x-http-method-override=PUT"
                serializedModel = serialize model
                request = Http.post url (Http.jsonBody serializedModel) (JSD.string)
            in
                (model, Http.send StateSaved request)
        StateSaved result ->
            (model, Notification.add AddNotification "State of your game is saved")
        RestoreState state ->
            (
                { model
                | cookies = state.cookies
                , producers = Producer.applyCounts model.producers state.producers
                }
            , Cmd.none
            )

