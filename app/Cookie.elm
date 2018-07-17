module Cookie exposing (..)


type alias State =
    Int


add : Int -> State -> State
add =
    (+)


increment =
    add 1


subtract : Int -> State -> State
subtract =
    (-)


cookie : String
cookie =
    "🍪"


cookiesPerSecond : State -> String
cookiesPerSecond cookies =
    (toString cookies) ++ cookie ++ "/s"
