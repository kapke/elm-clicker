module Msg exposing (..)

import Http
import Model exposing (SerializedModel)
import Notifications
import Producer exposing (Producer)
import Time exposing (Time)
import User exposing (UserId)


type Msg
    = MakeCookie
    | BuyProducer Producer
    | ProduceCookies Time
    | NotificationMsg Notifications.Msg
    | SetUserId UserId
    | SaveState
    | StateSaved (Result Http.Error String)
    | RestoreState UserId SerializedModel
    | RestoreStateFailed UserId String
