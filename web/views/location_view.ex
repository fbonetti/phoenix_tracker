defmodule PhoenixTracker.LocationView do
  use PhoenixTracker.Web, :view

  def render("index.json", %{locations: locations}) do
    locations
  end
end