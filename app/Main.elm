module Main exposing (..)

import Html
import Msg exposing (Msg(BuyProducer, MakeCookie, NotificationMsg, ProduceCookies, StatePersistenceMsg))
import Notification
import StatePersistence
import Time exposing (Time, second)

import Cookie exposing (cookie)
import Model exposing (Model)
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
        , notifications = Notification.initialState
        }
    , getUserId ""
    )

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every second Msg.ProduceCookies
        , if String.isEmpty model.userId then userId (\userId -> userId |> StatePersistence.SetUserId |> Msg.StatePersistenceMsg) else Sub.none
        , Time.every (10 * second) (\_ -> Msg.StatePersistenceMsg StatePersistence.SaveState)
        ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        MakeCookie ->
            ({ model | cookies = Cookie.add 1 model.cookies }, Cmd.none)
        BuyProducer producer ->
            if Producer.canBeBought producer model.cookies
            then
                (
                    { model
                    | cookies = Cookie.subtract producer.price model.cookies
                    , producers = Producer.buy producer model.producers
                    }
                , Cmd.none
                )
            else (model, Cmd.none)
        ProduceCookies time ->
            ({ model | cookies = Cookie.add model.cookies (Producer.produce model.producers)}, Cmd.none)
        NotificationMsg notificationMsg ->
            let (newNotifications, cmd) = Notification.update NotificationMsg notificationMsg model.notifications
            in ({model | notifications = newNotifications}, cmd)
        StatePersistenceMsg persistenceMsg ->
            StatePersistence.update StatePersistenceMsg (Notification.add (\notification -> notification |> Notification.AddNotification |> NotificationMsg )) persistenceMsg model

