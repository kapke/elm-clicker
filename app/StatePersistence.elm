module StatePersistence exposing (..)

import Http
import Json.Decode as JSD
import Json.Encode as JSE
import Model exposing (Model, SerializedModel)
import Producer exposing (SerializedProducer)
import Task
import Time exposing (Time)

type Msg =
    SetUserId String
    | SaveState
    | StateSaved (Result Http.Error String)
    | RestoreState SerializedModel
    | RestoreStateFailed String

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

restoreState : (Msg -> msg) -> String -> Cmd msg
restoreState wrapMsg userId =
    let
        url = "https://clicker-e237b.firebaseio.com/game-statuses/" ++ userId ++ ".json"
        requestTask = Http.get url stateJsonDecoder
            |> Http.toTask
            |> Task.mapError httpErrorToString
        responseToMsg response =
            case response of
                Result.Ok data -> RestoreState data
                Result.Err err -> RestoreStateFailed err
    in
        Task.attempt
            (\response -> response |> responseToMsg |> wrapMsg)
            requestTask


update : (Msg -> msg) -> (String -> Cmd msg) -> Msg -> Model -> (Model, Cmd msg)
update wrapMsg addNotification msg model =
    case msg of
        SaveState ->
            let
                userId = model.userId
                url = "https://clicker-e237b.firebaseio.com/game-statuses/" ++ userId ++ ".json?x-http-method-override=PUT"
                serializedModel = serialize model
                request = Http.post url (Http.jsonBody serializedModel) (JSD.string)
            in
                (model, Http.send (\result -> result |> StateSaved |> wrapMsg) request)
        StateSaved result ->
            (model, addNotification "State of your game is saved")
        RestoreState state ->
            (
                { model
                | cookies = state.cookies
                , producers = Producer.applyCounts model.producers state.producers
                }
            , Cmd.none
            )
        RestoreStateFailed err ->
            (model, addNotification err)
        SetUserId userId ->
            ( { model | userId = userId }
            , Cmd.batch
                [ addNotification ("User ID is set to " ++ userId)
                , restoreState (wrapMsg) userId
                ]
            )
