port module User exposing (..)

import Json.Decode

port getUserId : String -> Cmd msg

port userId : (String -> msg) -> Sub msg
