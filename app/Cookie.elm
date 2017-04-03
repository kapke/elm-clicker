module Cookie exposing (..)

import Html exposing (Html, div, img, span, text)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)


type alias State = Int

add : Int -> State -> State
add amount current =
    current + amount

subtract : Int -> State -> State
subtract amount current =
    current - amount

cookie : String
cookie = "🍪" -- here is unicode cookie char

cookiesPerSecond : Int -> String
cookiesPerSecond cookies =
    (toString cookies) ++ cookie ++ "/s"

