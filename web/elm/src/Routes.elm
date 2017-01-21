module Routes exposing (Route(..), parseRoute)

import Navigation exposing (Location)
import UrlParser exposing (Parser, map, oneOf, s, (<?>), parsePath, stringParam)


type Route
    = Logbook (Maybe String)
    | Stats (Maybe String)


router : Parser (Route -> a) a
router =
    oneOf
        [ map Logbook (s "logbook" <?> stringParam "date")
        , map Stats (s "stats" <?> stringParam "date")
        ]


parseRoute : Location -> Route
parseRoute =
    parsePath router >> Maybe.withDefault (Logbook Nothing)
