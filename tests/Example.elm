module Example exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)


suite : Test
suite =
    describe "Implement our first test. See http://package.elm-lang.org/packages/elm-community/elm-test/latest for how to do this!"
        [
            test "true" (\_ -> Expect.equal True True)
        ]
