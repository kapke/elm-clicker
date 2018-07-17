port module User exposing (..)

import Json.Decode


port getUserId : String -> Cmd msg


port userId : (String -> msg) -> Sub msg


type UserId
    = UserId String


userIdToString : UserId -> String
userIdToString id =
    case id of
        UserId str ->
            str
