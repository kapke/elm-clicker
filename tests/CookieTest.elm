module CookieTest exposing (..)

import String exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)

import Cookie exposing (..)


suite : Test
suite =
    describe "Cookie"
        [
            test "adding one more" (\_ -> 
                let expected = 3
                    actual = Cookie.add 1 2
                in 
                    Expect.equal expected actual
            ),
            test "subtracting one" (\_ -> 
                let expected = 2
                    actual = Cookie.subtract 1 3
                in Expect.equal expected actual
            ),
            fuzz int "cookies per second" (\cookies -> 
                Expect.all 
                    [ \actual -> Expect.true "Expected string to start with cookies count" (String.startsWith (toString cookies) actual)
                    , \actual -> Expect.true "Expected string to end with /s" (String.endsWith "/s" actual)
                    ] 
                    (Cookie.cookiesPerSecond cookies)
            )
        ]
