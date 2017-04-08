module Msg exposing (..)

import Notification exposing (Notification)
import Producer exposing (Producer)
import StatePersistence
import Time exposing (Time)


type Msg =
    MakeCookie
    | BuyProducer Producer
    | ProduceCookies Time
    | NotificationMsg Notification.Msg
    | StatePersistenceMsg StatePersistence.Msg
