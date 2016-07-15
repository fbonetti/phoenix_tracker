defmodule PhoenixTracker.LocationView do
  use PhoenixTracker.Web, :view

  def render("index.json", %{locations: locations}) do
    render_many(locations, PhoenixTracker.LocationView, "location.json")
  end

  def render("location.json", %{location: location}) do
    %{id: location.id,
      latitude: location.latitude,
      longitude: location.longitude,
      recorded_at: location.recorded_at
        |> Ecto.DateTime.to_erl
        |> :calendar.datetime_to_gregorian_seconds
        |> -(:calendar.datetime_to_gregorian_seconds({{1970, 1, 1}, {0, 0, 0}})) }
  end
end
