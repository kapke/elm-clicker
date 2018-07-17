module View exposing (..)

import Html exposing (Html, div, header, img, span, text)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)
import Model exposing (DataWithUser, DataWithoutUser, Model(WithUser, WithoutUser))
import Cookie
import Msg exposing (Msg(BuyProducer, MakeCookie))
import Notifications
import Producer


view : Model -> Html Msg
view model =
    let
        view =
            case model of
                WithUser r ->
                    playingView r

                WithoutUser r ->
                    initializingView r
    in
        div [ class "app" ] [ view ]


initializingView : DataWithoutUser -> Html Msg
initializingView model =
    div []
        [ div []
            [ Notifications.view model.notifications
            , span [] [ text "Initializing" ]
            ]
        ]


playingView : DataWithUser -> Html Msg
playingView model =
    div []
        [ cookie model.cookies
        , div []
            [ Notifications.view model.notifications
            , boughtStuff model.producers
            ]
        , shop model.producers
        ]


cookie : Cookie.State -> Html Msg
cookie cookiesCount =
    div [ class "cookie", onClick MakeCookie ]
        [ img [ src "img/cookie.jpg", class "cookie-img" ] []
        , span [ class "count" ] [ text (toString cookiesCount) ]
        ]


boughtStuff : Producer.State -> Html Msg
boughtStuff producers =
    let
        renderProducer producer =
            div [ class "bought-producer" ]
                [ span [ class "name" ] [ text producer.name ]
                , span [ class "current-production" ] [ producer |> Producer.currentProduction |> Cookie.cookiesPerSecond |> text ]
                , span [ class "bought-count" ] [ text (toString producer.boughtCount) ]
                ]
    in
        div [ class "bought-stuff" ] (List.map renderProducer producers)


shop : Producer.State -> Html Msg
shop producers =
    let
        renderProducer producer =
            div [ class "producer", onClick (BuyProducer producer) ]
                [ span [ class "name" ] [ text producer.name ]
                , span [ class "price" ] [ producer.price |> toString |> (++) Cookie.cookie |> text ]
                , span [ class "production" ] [ producer.production |> Cookie.cookiesPerSecond |> text ]
                ]
    in
        div [ class "shop" ]
            [ header [] [ text "Shop" ]
            , div [ class "producers" ] (List.map renderProducer producers)
            ]
