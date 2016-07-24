port module App exposing (..)

import Html exposing (Html, Attribute, button, div, text, h2, h3, select, option, span, i, form, input, img)
import Html.Attributes exposing (class, id, value, selected, type', multiple, action, method, name, enctype, src)
import Html.Events exposing (onInput, onClick)
import Html.App as Html
import Json.Decode as JD exposing ((:=))
import Http
import Task exposing (Task)
import Date exposing (Date)
import Date.Format
import Dict
import Json.Decode.Extra exposing ((|:))
import String
import Geodesy exposing (Coordinate)


main : Program Never
main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

init : ( Model, Cmd Msg )
init =
  ( model, Cmd.batch [ fetchPhotos, fetchLocations ] )


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- MODEL


type alias Model =
  { locations : List Location
  , photos : List Photo
  , error : String
  , dateFilter : String
  , tab : Tab
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

type alias Photo =
  { id : Int
  , latitude : Float
  , longitude : Float
  , originalUrl : String
  , thumbUrl : String
  , insertedAt : Float
  }

type Tab
  = Logbook
  | Photos
  | Stats

model : Model
model =
  { locations = []
  , photos = []
  , error = ""
  , dateFilter = ""
  , tab = Photos
  }


-- UPDATE


type Msg
  = SetLocations (List Location)
  | SetPhotos (List Photo)
  | SetError Http.Error
  | SetDateFilter String
  | SelectLocation Location
  | SetTab Tab
  | NoOp


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    SetLocations locations ->
      let
        model' = { model | locations = locations }
        cmd = outgoingLocationsAndPhotos ( filteredLocations model', filteredPhotos model' )
      in
        ( model',  cmd )
    SetPhotos photos ->
      let
        model' = { model | photos = photos }
        cmd = outgoingLocationsAndPhotos ( filteredLocations model', filteredPhotos model' )
      in
        ( model',  cmd )
    SetError error ->
      ( { model | error = toString error }, Cmd.none )
    SetDateFilter dateFilter ->
      let
        model' = { model | dateFilter = dateFilter }
        cmd = outgoingLocationsAndPhotos ( filteredLocations model', filteredPhotos model' )
      in
        ( model',  cmd )
    SelectLocation location ->
      ( model, selectLocation location )
    SetTab tab ->
      ( { model | tab = tab }, Cmd.none )
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

filteredPhotos : Model -> List Photo
filteredPhotos { dateFilter, photos } =
  if dateFilter == "" then
    photos
  else
    List.filter
      (\photo -> (unixToDate >> dateToIso) photo.insertedAt == dateFilter)
      photos


-- COMMANDS

port outgoingLocationsAndPhotos : ( List Location, List Photo ) -> Cmd msg
port selectLocation : Location -> Cmd msg

fetchLocations : Cmd Msg
fetchLocations =
  Http.get locationsDecoder "/api/locations"
    |> Task.perform SetError SetLocations

fetchPhotos : Cmd Msg
fetchPhotos =
  Http.get photosDecoder "/api/photos"
    |> Task.perform SetError SetPhotos

-- HELPERS


classNames : List ( String, Bool ) -> Attribute Msg
classNames =
  List.filter snd >> List.map fst >> String.join " " >> class

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
    buildDict = List.foldl (\item dict -> Dict.insert (fn item) item dict) Dict.empty
  in
    buildDict >> Dict.values

locationCoordinates : Location -> Coordinate
locationCoordinates { latitude, longitude } =
  ( latitude, longitude )

zip : List a -> List b -> List (a,b)
zip = List.map2 (,)

pairs : List a -> List (a,a)
pairs list =
  case list of
    [] -> []
    xs -> zip xs (List.tail xs |> Maybe.withDefault [])

roundToNDecimalPlaces : Int -> Float -> Float
roundToNDecimalPlaces n num =
  num * (toFloat (10 ^ n))
    |> round
    |> toFloat
    |> flip (/) (toFloat (10 ^ n))

-- DECODERS


locationDecoder : JD.Decoder Location
locationDecoder =
  JD.succeed Location
    |: ("id" := JD.int)
    |: ("latitude" := JD.float)
    |: ("longitude" := JD.float)
    |: ("recorded_at" := JD.float)
    |: ("battery_state" := JD.string)
    |: ("message_type" := JD.string)
    |: (JD.maybe ("message_content" := JD.string))
    |: (JD.maybe ("summary" := JD.string))
    |: (JD.maybe ("icon" := JD.string))
    |: (JD.maybe ("temperature" := JD.float))
    |: (JD.maybe ("humidity" := JD.float))
    |: (JD.maybe ("visibility" := JD.float))
    |: (JD.maybe ("wind_bearing" := JD.float))
    |: (JD.maybe ("wind_speed" := JD.float))

locationsDecoder : JD.Decoder (List Location)
locationsDecoder =
  JD.list locationDecoder

photoDecoder : JD.Decoder Photo
photoDecoder =
  JD.succeed Photo
    |: ("id" := JD.int)
    |: ("latitude" := JD.float)
    |: ("longitude" := JD.float)
    |: ("original_url" := JD.string)
    |: ("thumb_url" := JD.string)
    |: ("inserted_at" := JD.float)

photosDecoder : JD.Decoder (List Photo)
photosDecoder =
  JD.list photoDecoder

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
          [ h2 [ classNames [ ("tab", True), ("active", model.tab == Logbook) ], onClick (SetTab Logbook) ]
              [ text "Logbook"
              ]
          , h2 [ classNames [ ("tab", True), ("active", model.tab == Photos) ], onClick (SetTab Photos) ]
              [ text "Photos"
              ]
          , h2 [ classNames [ ("tab", True), ("active", model.tab == Stats) ], onClick (SetTab Stats) ]
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
    Photos ->
      renderPhotos (filteredPhotos model)
    Stats ->
      renderStats (filteredLocations model)

photoUploadForm : Html Msg
photoUploadForm =
  form [ action "/photos/upload", method "POST", enctype "multipart/form-data" ]
    [ input [ type' "file", multiple False, name "asset" ] []
    , input [ type' "submit" ] []
    ]

renderPhotos : List Photo -> Html Msg
renderPhotos photos =
  div [ class "panel-content" ]
    [ photoUploadForm
    , div [ class "photos" ] (List.map renderPhoto photos)
    ]

renderPhoto : Photo -> Html Msg
renderPhoto { thumbUrl } =
  img [ class "photo", src thumbUrl ] []

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

{- Sum of all distances between coordinate pairs
-}
distanceTraveled : List Location -> Float
distanceTraveled =
  List.map locationCoordinates
    >> pairs
    >> List.foldl (\(first, second) dist -> dist + (Geodesy.distance first second Geodesy.Miles)) 0


{- Distance between first and last location
-}
totalDisplacement : List Location -> Float
totalDisplacement locations =
  let
    coordinateList = List.map locationCoordinates locations
    head = List.head coordinateList
    last = (List.head << List.reverse) coordinateList
  in
    Maybe.map2 (\head' tail' -> Geodesy.distance head' tail' Geodesy.Miles) head last
      |> Maybe.withDefault 0


renderDateFilter : Model -> Html Msg
renderDateFilter { locations, dateFilter } =
  let
    mapping date =
      let
        value' = dateToIso date
        label' = Date.Format.format "%a, %b %d %Y" date
      in
        option [ value value', selected (value' == dateFilter) ] [ text label' ]
    options = List.map mapping (uniqueLocationDates locations)
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
    Just "clear-day" -> "wi-day-sunny"
    Just "clear-night" -> "wi-night-clear"
    Just "rain" -> "wi-rain"
    Just "snow" -> "wi-snow"
    Just "sleet" -> "wi-sleet"
    Just "wind" -> "wi-windy"
    Just "fog" -> "wi-fog"
    Just "cloudy" -> "wi-cloudy"
    Just "partly-cloudy-day" -> "wi-day-cloudy"
    Just "partly-cloudy-night" -> "wi-night-partly-cloudy"
    _ -> "wi-na"

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
