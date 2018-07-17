module Main exposing (..)

import Html
import Http
import Msg exposing (Msg)
import Notifications
import StatePersistence exposing (restoreState, saveState)
import Task
import Time exposing (Time, second)
import Cookie exposing (cookie)
import Model exposing (Model(WithUser, WithoutUser), overCookies, tryBuyProducer)
import Producer exposing (Producer)
import User exposing (UserId(UserId), getUserId, userId, userIdToString)
import View exposing (view)
import Utils.Result exposing (toMsg)


main =
    Html.program { init = init, view = view, update = update, subscriptions = subscriptions }


init : ( Model, Cmd Msg )
init =
    ( WithoutUser
        { notifications = Notifications.initialState
        }
    , getUserId ""
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every second Msg.ProduceCookies
        , Time.every (10 * second) (always Msg.SaveState)
        , case model of
            WithUser r ->
                Sub.none

            WithoutUser r ->
                userId <| UserId >> Msg.SetUserId
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        addNotification =
            Notifications.add >> Cmd.map Msg.NotificationMsg

        handleNotifications notificationMsg record =
            let
                ( newNotifications, cmd ) =
                    Notifications.update notificationMsg record.notifications
            in
                ( { record | notifications = newNotifications }, Cmd.map (Msg.NotificationMsg) cmd )
    in
        case model of
            WithoutUser state ->
                case msg of
                    Msg.NotificationMsg notificationMsg ->
                        Tuple.mapFirst WithoutUser (handleNotifications notificationMsg state)

                    Msg.SetUserId userId ->
                        ( model
                        , Cmd.batch
                            [ addNotification ("User ID is set to " ++ (userId |> userIdToString))
                            , restoreState (toMsg (Msg.RestoreStateFailed userId) (Msg.RestoreState userId)) userId
                            ]
                        )

                    Msg.RestoreState userId serialized ->
                        ( Model.restore userId serialized state, Cmd.none )

                    Msg.RestoreStateFailed userId err ->
                        ( WithUser (Model.emptyDataWithUser userId model), addNotification err )

                    _ ->
                        ( model, Cmd.none )

            WithUser state ->
                Tuple.mapFirst (WithUser)
                    (case msg of
                        Msg.MakeCookie ->
                            ( overCookies Cookie.increment state, Cmd.none )

                        Msg.BuyProducer producer ->
                            ( tryBuyProducer producer state, Cmd.none )

                        Msg.ProduceCookies time ->
                            ( overCookies (Cookie.add (Producer.sumProduction state.producers)) state, Cmd.none )

                        Msg.SaveState ->
                            ( state, (saveState (Msg.StateSaved) model state.userId) )

                        Msg.StateSaved result ->
                            ( state, addNotification "State of your game is saved" )

                        Msg.NotificationMsg notificationMsg ->
                            handleNotifications notificationMsg state

                        _ ->
                            ( state, Cmd.none )
                    )
