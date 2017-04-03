module Notification exposing (..)

import Process
import Random exposing (initialSeed, maxInt, minInt)
import Task exposing (map)
import Time

type alias Notification =
    { text : String
    , id : Int
    }

add : (Notification -> msg) -> String -> Cmd msg
add tagger notification =
    Task.perform tagger (Time.now
        |> map (\time -> round (Time.inMilliseconds time))
        |> map (\seed -> Random.step (Random.int minInt maxInt) (initialSeed seed))
        |> map Tuple.first
        |> map (\id -> Notification notification id))

remove : (Notification -> msg) -> Notification -> Cmd msg
remove tagger notification =
    Task.perform tagger (Process.sleep (5 * Time.second)
        |> Task.andThen (always <| Task.succeed notification))

