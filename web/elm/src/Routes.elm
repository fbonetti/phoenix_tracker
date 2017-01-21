module Routes exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (Parser, (</>), s, int, string, map, oneOf, parseHash)


type Route
    = Blog Int
    | Search String


route : Parser (Route -> a) a
route =
    oneOf
        [ map Blog (s "blog" </> int)
        ]
