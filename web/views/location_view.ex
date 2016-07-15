defmodule PhoenixTracker.LocationView do
  use PhoenixTracker.Web, :view

  def render("index.json", %{locations: locations}) do
    %{data: render_many(locations, PhoenixTracker.LocationView, "location.json")}
  end
end
