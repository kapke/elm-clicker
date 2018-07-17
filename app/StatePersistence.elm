module StatePersistence exposing (..)

import Http
import Json.Decode as JSD
import Json.Encode as JSE
import Model exposing (Model, SerializedModel, serialize, stateJsonDecoder)
import Msg exposing (Msg)
import Task
import Time exposing (Time)
import User exposing (UserId, userIdToString)


getUrl : UserId -> String
getUrl userId =
    "https://clicker-e237b.firebaseio.com/game-statuses/" ++ (userIdToString userId) ++ ".json"


saveUrl : UserId -> String
saveUrl userId =
    "https://clicker-e237b.firebaseio.com/game-statuses/" ++ (userIdToString userId) ++ ".json?x-http-method-override=PUT"


httpErrorToString : Http.Error -> String
httpErrorToString err =
    "Something went wrong with making request to game server. Check internet connection"


restoreState : (Result String SerializedModel -> Msg) -> UserId -> Cmd Msg
restoreState responseToMsg userId =
    Http.get (getUrl userId) stateJsonDecoder
        |> Http.toTask
        |> Task.mapError httpErrorToString
        |> Task.attempt (responseToMsg)


saveState : (Result Http.Error String -> Msg) -> Model -> UserId -> Cmd Msg
saveState resultToMsg model userId =
    let
        url =
            saveUrl userId

        serializedModel =
            model |> serialize |> Http.jsonBody

        request =
            Http.post url serializedModel (JSD.string)
    in
        Http.send (resultToMsg) request
