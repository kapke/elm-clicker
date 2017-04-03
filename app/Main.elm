module Main exposing (..)

import Html
import Time exposing (Time, second)

import Cookie exposing (cookie)
import Model exposing (Model, Msg(ProduceCookies, SaveState, SetUserId), update)
import Producer exposing (Producer)
import User exposing (getUserId, userId)
import View exposing (view)


main =
    Html.program { init = init, view = view, update = update, subscriptions = subscriptions }

init : (Model, Cmd Msg)
init =
    (
        { cookies = 0
        , producers =
            [ Producer "Grandma" 1 10 0
            , Producer "Bakery" 5 500 0
            , Producer "Factory" 20 1000 0
            , Producer "Mine" 50 5000 0
            ]
        , userId = ""
        , notifications = []
        }
    , getUserId ""
    )



subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every second ProduceCookies
        , if String.isEmpty model.userId then userId SetUserId else Sub.none
        , Time.every (10 * second) SaveState
        ]
