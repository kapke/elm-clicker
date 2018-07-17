module Notifications exposing (Notification, Notifications, Msg(AddNotification), State, initialState, update, add, view)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Process
import Random exposing (initialSeed, maxInt, minInt)
import Task exposing (map)
import Time
import Utils.List exposing (append)


type alias Notification =
    { text : String
    , id : Int
    }


type alias Notifications =
    List Notification


type alias State =
    { notifications : Notifications
    , lastId : Int
    }


type Msg
    = AddNotification String
    | RemoveNotification Notification


initialState : State
initialState =
    { notifications = [], lastId = 0 }


update : Msg -> State -> ( State, Cmd Msg )
update msg state =
    case msg of
        AddNotification text ->
            let
                id =
                    nextId state

                notification =
                    Notification text id

                newState =
                    state |> overNotifications (append notification) |> setLastId id
            in
                ( newState, remove notification )

        RemoveNotification notification ->
            ( overNotifications (removeNotification notification) state
            , Cmd.none
            )


view : State -> Html msg
view notificationsState =
    let
        notifications =
            notificationsState.notifications

        renderNotification notification =
            div [ class "notification" ] [ text notification.text ]
    in
        div [ class "notifications" ] (List.map renderNotification notifications)


add : String -> Cmd Msg
add text =
    Task.perform (AddNotification) (Task.succeed text)


remove : Notification -> Cmd Msg
remove notification =
    Task.perform (RemoveNotification)
        ((5 * Time.second)
            |> Process.sleep
            |> Task.map (always notification)
            |> Task.andThen (Task.succeed)
        )


nextId : State -> Int
nextId state =
    state.lastId + 1


overNotifications : (Notifications -> Notifications) -> State -> State
overNotifications mapper state =
    { state | notifications = mapper state.notifications }


removeNotification : Notification -> Notifications -> Notifications
removeNotification notification notifications =
    List.filter (\n -> n.id /= notification.id) notifications


setLastId : Int -> State -> State
setLastId id state =
    { state | lastId = id }
