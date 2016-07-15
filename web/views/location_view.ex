defmodule PhoenixTracker.LocationView do
  use PhoenixTracker.Web, :view

  def render("index.json", %{locations: locations}) do
    %{data: render_many(locations, PhoenixTracker.LocationView, "location.json")}
  end

  def render("location.json", %{location: location}) do
    %{id: location.id,
      latitude: location.latitude,
      longitude: location.longitude,
      recorded_at: location.recorded_at}
  end
end
