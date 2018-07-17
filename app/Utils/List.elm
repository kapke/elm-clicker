module Utils.List exposing (..)


append : a -> List a -> List a
append element list =
    list |> List.reverse |> (::) element |> List.reverse


overMatching : (a -> Bool) -> (a -> a) -> List a -> List a
overMatching predicate mapper list =
    List.map
        (\item ->
            if (predicate item) then
                mapper item
            else
                item
        )
        list
