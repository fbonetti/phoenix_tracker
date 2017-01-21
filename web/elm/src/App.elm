port module App exposing (..)

import Html exposing (Html, Attribute, button, div, text, h2, h3, select, option, span, i)
import Html.Attributes exposing (class, id, value, selected)
import Html.Events exposing (onInput, onClick)
import Json.Decode as JD exposing (field)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Http
import Result.Utils as Result
import Date exposing (Date)
import Date.Format
import Dict
import String
import Geodesy exposing (Coordinate)
import Tuple exposing (first, second)
import Navigation
import Routes exposing (parseRoute)


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Navigation.Location -> ( Model, Cmd Msg )
init urlLocation =
    ( initModel urlLocation, fetchLocations )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MODEL


type alias Model =
    { locations : List Location
    , error : String
    , dateFilter : String
    , tab : Tab
    , urlLocation : Navigation.Location
    }


type alias Location =
    { id : Int
    , latitude : Float
    , longitude : Float
    , recordedAt : Float
    , batteryState : String
    , messageType : String
    , messageContent : Maybe String
    , summary : Maybe String
    , icon : Maybe String
    , temperature : Maybe Float
    , humidity : Maybe Float
    , visibility : Maybe Float
    , windBearing : Maybe Float
    , windSpeed : Maybe Float
    }


type Tab
    = Logbook
    | Stats


initModel : Navigation.Location -> Model
initModel urlLocation =
    let
        model =
            { locations = []
            , error = ""
            , dateFilter = ""
            , tab = Logbook
            , urlLocation = urlLocation
            }
    in
        handleUrlChange urlLocation model



-- UPDATE


type Msg
    = UrlChange Navigation.Location
    | SetLocations (List Location)
    | SetError Http.Error
    | SetDateFilter String
    | SelectLocation Location
    | SelectTab Tab
    | NoOp


handleUrlChange : Navigation.Location -> Model -> Model
handleUrlChange urlLocation model =
    case parseRoute urlLocation of
        Routes.Logbook date ->
            { model
                | dateFilter = Maybe.withDefault "" date
                , tab = Logbook
            }

        Routes.Stats date ->
            { model
                | dateFilter = Maybe.withDefault "" date
                , tab = Stats
            }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChange urlLocation ->
            let
                model_ =
                    handleUrlChange urlLocation model

                cmd =
                    (filteredLocations >> outgoingLocations) model_
            in
                ( model_, cmd )

        SetLocations locations ->
            let
                model_ =
                    { model | locations = locations }

                cmd =
                    (filteredLocations >> outgoingLocations) model_
            in
                ( model_, cmd )

        SetError error ->
            ( { model | error = toString error }, Cmd.none )

        SetDateFilter dateFilter ->
            ( model, changeUrlDateParam model dateFilter )

        SelectLocation location ->
            ( model, selectLocation location )

        SelectTab tab ->
            case tab of
                Logbook ->
                    ( model, changeUrlPath model "logbook" )

                Stats ->
                    ( model, changeUrlPath model "stats" )

        NoOp ->
            ( model, Cmd.none )


filteredLocations : Model -> List Location
filteredLocations { dateFilter, locations } =
    if dateFilter == "" then
        locations
    else
        List.filter
            (\location -> (unixToDate >> dateToIso) location.recordedAt == dateFilter)
            locations



-- COMMANDS


port outgoingLocations : List Location -> Cmd msg


port selectLocation : Location -> Cmd msg


fetchLocations : Cmd Msg
fetchLocations =
    Http.get "/api/locations" locationsDecoder
        |> Http.send (Result.unify SetError SetLocations)


changeUrlPath : Model -> String -> Cmd Msg
changeUrlPath { urlLocation, dateFilter } path =
    let
        params =
            if String.isEmpty dateFilter then
                ""
            else
                "?date=" ++ dateFilter
    in
        Navigation.newUrl ("/" ++ path ++ params)


changeUrlDateParam : Model -> String -> Cmd Msg
changeUrlDateParam { urlLocation, tab } dateFilter =
    let
        params =
            if String.isEmpty dateFilter then
                ""
            else
                "?date=" ++ dateFilter

        path =
            case tab of
                Logbook ->
                    "logbook"

                Stats ->
                    "stats"
    in
        Navigation.newUrl (urlLocation.origin ++ "/" ++ path ++ params)



-- HELPERS


classNames : List ( String, Bool ) -> Attribute Msg
classNames =
    List.filter second >> List.map first >> String.join " " >> class


unixToDate : Float -> Date
unixToDate =
    (*) 1000 >> Date.fromTime


dateToIso : Date -> String
dateToIso =
    Date.Format.format "%Y-%m-%d"


coordinatesToString : ( Float, Float ) -> String
coordinatesToString ( latitude, longitude ) =
    (toString latitude) ++ ", " ++ (toString longitude)


formatTimestamp : Date -> String
formatTimestamp =
    Date.Format.format "%a, %b %d %Y @ %l:%M:%S %P"


uniqBy : (a -> comparable) -> List a -> List a
uniqBy fn =
    let
        buildDict =
            List.foldl (\item dict -> Dict.insert (fn item) item dict) Dict.empty
    in
        buildDict >> Dict.values


locationCoordinates : Location -> Coordinate
locationCoordinates { latitude, longitude } =
    ( latitude, longitude )


zip : List a -> List b -> List ( a, b )
zip =
    List.map2 (,)


pairs : List a -> List ( a, a )
pairs list =
    case list of
        [] ->
            []

        xs ->
            zip xs (List.tail xs |> Maybe.withDefault [])


roundToNDecimalPlaces : Int -> Float -> Float
roundToNDecimalPlaces n num =
    num
        * (toFloat (10 ^ n))
        |> round
        |> toFloat
        |> flip (/) (toFloat (10 ^ n))



-- DECODERS


locationDecoder : JD.Decoder Location
locationDecoder =
    decode Location
        |> required "id" JD.int
        |> required "latitude" JD.float
        |> required "longitude" JD.float
        |> required "recorded_at" JD.float
        |> required "battery_state" JD.string
        |> required "message_type" JD.string
        |> required "message_content" (JD.nullable JD.string)
        |> required "summary" (JD.nullable JD.string)
        |> required "icon" (JD.nullable JD.string)
        |> required "temperature" (JD.nullable JD.float)
        |> required "humidity" (JD.nullable JD.float)
        |> required "visibility" (JD.nullable JD.float)
        |> required "wind_bearing" (JD.nullable JD.float)
        |> required "wind_speed" (JD.nullable JD.float)


locationsDecoder : JD.Decoder (List Location)
locationsDecoder =
    JD.list locationDecoder


uniqueLocationDates : List Location -> List Date
uniqueLocationDates locations =
    List.map (\location -> unixToDate location.recordedAt) locations
        |> uniqBy dateToIso
        |> List.reverse



-- VIEW


toText : a -> Html Msg
toText =
    toString >> text


nothing : Html Msg
nothing =
    text ""


view : Model -> Html Msg
view model =
    div [ id "elm-container" ]
        [ div [ id "map" ] []
        , div [ id "info" ]
            [ div [ class "tabs" ]
                [ h2 [ classNames [ ( "tab", True ), ( "active", model.tab == Logbook ) ], onClick (SelectTab Logbook) ]
                    [ text "Logbook"
                    ]
                , h2 [ classNames [ ( "tab", True ), ( "active", model.tab == Stats ) ], onClick (SelectTab Stats) ]
                    [ text "Stats"
                    ]
                ]
            , div [ class "filters" ]
                [ renderDateFilter model
                ]
            , renderSection model
            ]
        ]


renderSection : Model -> Html Msg
renderSection model =
    case model.tab of
        Logbook ->
            renderLocations (filteredLocations model)

        Stats ->
            renderStats (filteredLocations model)


renderStats : List Location -> Html Msg
renderStats locations =
    div [ class "panel-content" ]
        [ h3 [] [ text "Distance traveled" ]
        , (distanceTraveled >> roundToNDecimalPlaces 2 >> toText) locations
        , text " miles"
        , h3 [] [ text "Displacement" ]
        , (totalDisplacement >> roundToNDecimalPlaces 2 >> toText) locations
        , text " miles"
        , h3 [] [ text "# of Data points" ]
        , (List.length >> toText) locations
        ]



{- Sum of all distances between coordinate pairs -}


distanceTraveled : List Location -> Float
distanceTraveled =
    List.map locationCoordinates
        >> pairs
        >> List.foldl (\( first, second ) dist -> dist + (Geodesy.distance first second Geodesy.Miles)) 0



{- Distance between first and last location -}


totalDisplacement : List Location -> Float
totalDisplacement locations =
    let
        coordinateList =
            List.map locationCoordinates locations

        head =
            List.head coordinateList

        last =
            (List.head << List.reverse) coordinateList
    in
        Maybe.map2 (\head_ tail_ -> Geodesy.distance head_ tail_ Geodesy.Miles) head last
            |> Maybe.withDefault 0


renderDateFilter : Model -> Html Msg
renderDateFilter { locations, dateFilter } =
    let
        mapping date =
            let
                value_ =
                    dateToIso date

                label_ =
                    Date.Format.format "%a, %b %d %Y" date
            in
                option [ value value_, selected (value_ == dateFilter) ] [ text label_ ]

        options =
            List.map mapping (uniqueLocationDates locations)
    in
        select [ class "form-control", onInput SetDateFilter ]
            ([ option [ value "" ] [ text "Show all" ] ] ++ options)


renderLocations : List Location -> Html Msg
renderLocations locations =
    div [ class "panel-content" ] (List.map renderLocation locations)


renderLocation : Location -> Html Msg
renderLocation location =
    div [ class "location-block", onClick (SelectLocation location) ]
        [ div [ class "location-info" ]
            [ div []
                [ (unixToDate >> formatTimestamp >> text) location.recordedAt
                ]
            , div [ class "location-icons" ]
                [ messageTypeIcon location.messageType
                , weatherIcon location.icon
                , batteryStateIcon location.batteryState
                ]
            ]
        ]


batteryStateIcon : String -> Html Msg
batteryStateIcon batteryState =
    case batteryState of
        "GOOD" ->
            i [ class "fa fa-battery-full" ] []

        _ ->
            i [ class "fa fa-battery-quarter" ] []


weatherIconClass : Maybe String -> String
weatherIconClass icon =
    case icon of
        Just "clear-day" ->
            "wi-day-sunny"

        Just "clear-night" ->
            "wi-night-clear"

        Just "rain" ->
            "wi-rain"

        Just "snow" ->
            "wi-snow"

        Just "sleet" ->
            "wi-sleet"

        Just "wind" ->
            "wi-windy"

        Just "fog" ->
            "wi-fog"

        Just "cloudy" ->
            "wi-cloudy"

        Just "partly-cloudy-day" ->
            "wi-day-cloudy"

        Just "partly-cloudy-night" ->
            "wi-night-partly-cloudy"

        _ ->
            "wi-na"


weatherIcon : Maybe String -> Html Msg
weatherIcon icon =
    i [ class ("wi " ++ weatherIconClass icon) ] []


messageTypeIcon : String -> Html Msg
messageTypeIcon messageType =
    case messageType of
        "OK" ->
            i [ class "fa fa-check" ] []

        "CUSTOM" ->
            i [ class "fa fa-comment-o" ] []

        _ ->
            nothing
