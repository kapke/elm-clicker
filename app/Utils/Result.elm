module Utils.Result exposing (..)

import Msg exposing (Msg)


toMsg : (err -> Msg) -> (value -> Msg) -> Result err value -> Msg
toMsg errMsg okMsg result =
    case result of
        Result.Ok data ->
            okMsg data

        Result.Err err ->
            errMsg err
