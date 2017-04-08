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
    , notifications : Notification.State
    }

type alias SerializedModel =
    { cookies : Int
    , producers : List SerializedProducer
    }
