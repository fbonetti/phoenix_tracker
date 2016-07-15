port module App exposing (..)

import Html exposing (Html, button, div, text, h1, table, thead, tbody, th, tr, td)
import Html.Attributes exposing (class, id)
import Html.App as Html
import Json.Decode as JD exposing ((:=))
import Http
import Task exposing (Task)
import Date exposing (Date)


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
  }

type alias Location =
  { id : Int
  , latitude : Float
  , longitude : Float
  , recorded_at : Float
  }

model : Model
model =
  { locations = []
  , error = ""
  }


-- UPDATE


type Msg
  = SetLocations (List Location)
  | SetError Http.Error
  | NoOp


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    SetLocations locations ->
      ( { model | locations = locations }, outgoingLocations locations )
    SetError error ->
      ( { model | error = toString error }, Cmd.none )
    NoOp ->
      ( model, Cmd.none )


-- COMMANDS


getLocations : Cmd Msg
getLocations =
  Http.get locationsDecoder "/api/locations"
    |> Task.perform SetError SetLocations


-- HELPERS


unixToDate : Float -> Date
unixToDate =
  (*) 1000 >> Date.fromTime


-- DECODERS


locationDecoder : JD.Decoder Location
locationDecoder =
  JD.object4
    Location
    ("id" := JD.int)
    ("latitude" := JD.float)
    ("longitude" := JD.float)
    ("recorded_at" := JD.float)
    

locationsDecoder : JD.Decoder (List Location)
locationsDecoder =
  JD.list locationDecoder


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
      , div [ class "flex-1 overflow-y-scroll" ]
          [ renderLocations model.locations
          ]
      ]
    ]

renderLocations : List Location -> Html Msg
renderLocations locations =
  table [ class "table" ]
    [ thead []
        [ th [] [ text "ID" ]
        , th [] [ text "Latitude" ]
        , th [] [ text "Longitude" ]
        , th [] [ text "Timestamp" ]
        ]
    , tbody [] (List.map renderLocation locations)
    ]

renderLocation : Location -> Html Msg
renderLocation location =
  tr []
    [ td [] [ toText location.id ]
    , td [] [ toText location.latitude ]
    , td [] [ toText location.longitude ]
    , td [] [ (unixToDate >> toText) location.recorded_at ]
    ]
