port module App exposing (..)

import Html exposing (Html, button, div, text, h2, select, option, span, i)
import Html.Attributes exposing (class, id, value, selected)
import Html.Events exposing (onInput, onClick)
import Html.App as Html
import Json.Decode as JD exposing ((:=))
import Http
import Task exposing (Task)
import Date exposing (Date)
import Date.Format
import Dict
import Json.Decode.Extra exposing ((|:))


main : Program Never
main =
  Html.program
    { init = (model, fetchLocations)
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- MODEL


type alias Model =
  { locations : List Location
  , error : String
  , dateFilter : String
  }

type alias Location =
  { id : Int
  , latitude : Float
  , longitude : Float
  , recordedAt : Float
  , batteryState : String
  , summary : String
  , icon : String
  , temperature : Float
  , humidity : Float
  , visibility : Float
  , windBearing : Float
  , windSpeed : Float
  }

model : Model
model =
  { locations = []
  , error = ""
  , dateFilter = ""
  }


-- UPDATE


type Msg
  = SetLocations (List Location)
  | SetError Http.Error
  | SetDateFilter String
  | SelectLocation Location
  | NoOp


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    SetLocations locations ->
      let
        model' = { model | locations = locations }
        cmd = (filteredLocations >> outgoingLocations) model'
      in
        ( model',  cmd )
    SetError error ->
      ( { model | error = toString error }, Cmd.none )
    SetDateFilter dateFilter ->
      let
        model' = { model | dateFilter = dateFilter }
        cmd = (filteredLocations >> outgoingLocations) model'
      in
        ( model',  cmd )
    SelectLocation location ->
      ( model, selectLocation location )
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
  Http.get locationsDecoder "/api/locations"
    |> Task.perform SetError SetLocations


-- HELPERS


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

-- DECODERS


locationDecoder : JD.Decoder Location
locationDecoder =
  JD.succeed Location
    |: ("id" := JD.int)
    |: ("latitude" := JD.float)
    |: ("longitude" := JD.float)
    |: ("recorded_at" := JD.float)
    |: ("battery_state" := JD.string)
    |: ("summary" := JD.string)
    |: ("icon" := JD.string)
    |: ("temperature" := JD.float)
    |: ("humidity" := JD.float)
    |: ("visibility" := JD.float)
    |: ("wind_bearing" := JD.float)
    |: ("wind_speed" := JD.float)

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

view : Model -> Html Msg
view model =
  div [ id "elm-container" ]
    [ div [ id "map" ] []
    , div [ id "info" ]
      [ h2 [ class "title" ] [ text "Locations" ]
      , div [ class "filters" ]
          [ renderDateFilter model
          ]
      , renderLocations (filteredLocations model)
      ]
    ]

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
  div [ class "location-list" ] (List.map renderLocation locations)

renderLocation : Location -> Html Msg
renderLocation location =
  div [ class "location-block", onClick (SelectLocation location) ]
    [ div [ class "location-info" ]
      [ div []
        [ (unixToDate >> formatTimestamp >> text) location.recordedAt
        ]
      , div [ class "flex-1 text-right" ]
        [ weatherIcon ""
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
      i [ class "fa fa-battery-full" ] []

weatherIcon : String -> Html Msg
weatherIcon _ =
  i [ class "wi wi-day-lightning" ] []  
