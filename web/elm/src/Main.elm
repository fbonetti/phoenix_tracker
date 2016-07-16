port module App exposing (..)

import Html exposing (Html, button, div, text, h1, table, thead, tbody, th, tr, td, label, fieldset, select, option)
import Html.Attributes exposing (class, id, value, selected)
import Html.Events exposing (onInput)
import Html.App as Html
import Json.Decode as JD exposing ((:=))
import Http
import Task exposing (Task)
import Date exposing (Date)
import Date.Format
import Set


main : Program Never
main =
  Html.program
    { init = (model, getLocations)
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

port outgoingLocations : List Location -> Cmd msg

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
  | NoOp


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    SetLocations locations ->
      ( { model | locations = locations }, outgoingLocations locations )
    SetError error ->
      ( { model | error = toString error }, Cmd.none )
    SetDateFilter dateFilter ->
      ( { model | dateFilter = dateFilter }, Cmd.none )
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


getLocations : Cmd Msg
getLocations =
  Http.get locationsDecoder "/api/locations"
    |> Task.perform SetError SetLocations


-- HELPERS


unixToDate : Float -> Date
unixToDate =
  (*) 1000 >> Date.fromTime

dateToIso : Date -> String
dateToIso =
  Date.Format.format "%Y-%m-%d"

-- DECODERS


locationDecoder : JD.Decoder Location
locationDecoder =
  JD.object5
    Location
    ("id" := JD.int)
    ("latitude" := JD.float)
    ("longitude" := JD.float)
    ("recorded_at" := JD.float)
    ("battery_state" := JD.string)
    

locationsDecoder : JD.Decoder (List Location)
locationsDecoder =
  JD.list locationDecoder

uniqueLocationDates : List Location -> List String
uniqueLocationDates locations =
  List.map (\location -> (unixToDate >> dateToIso) location.recordedAt) locations
    |> Set.fromList
    |> Set.toList
    |> List.reverse

-- VIEW


toText : a -> Html Msg
toText =
  toString >> text

view : Model -> Html Msg
view model =
  div [ class "row full-height" ]
    [ div [ id "map", class "col-sm-6" ] []
    , div [ class "col-sm-6 display-flex flex-direction-column" ]
      [ h1 [] [ text "Locations" ]
      , div [ class "row" ]
          [ div [ class "col-sm-6" ] [ dateFilter model ]
          ]
      , div [ class "flex-1 overflow-y-scroll" ]
          [ renderLocations (filteredLocations model)
          ]
      ]
    ]

dateFilter : Model -> Html Msg
dateFilter { locations, dateFilter } =
  let
    options = List.map
      (\date -> option [ value date, selected (date == dateFilter) ] [ text date ])
      (uniqueLocationDates locations)
  in
    fieldset [ class "form-group" ]
      [ label [] [ text "Date" ]
      , select [ class "form-control", onInput SetDateFilter ]
          ([ option [ value "" ] [ text "Show all" ] ] ++ options)
      ]

renderLocations : List Location -> Html Msg
renderLocations locations =
  table [ class "table table-sm" ]
    [ thead []
        [ th [] [ text "ID" ]
        , th [] [ text "Latitude" ]
        , th [] [ text "Longitude" ]
        , th [] [ text "Timestamp" ]
        , th [] [ text "Battery" ]
        ]
    , tbody [] (List.map renderLocation locations)
    ]

renderLocation : Location -> Html Msg
renderLocation location =
  tr []
    [ td [] [ toText location.id ]
    , td [] [ toText location.latitude ]
    , td [] [ toText location.longitude ]
    , td [] [ (unixToDate >> toText) location.recordedAt ]
    , td [] [ text location.batteryState ]
    ]
