defmodule PhoenixTracker.LocationController do
  use PhoenixTracker.Web, :controller
  alias PhoenixTracker.Location

  def index(conn, _params) do
    locations = Repo.all(Location)
    render conn, locations: locations
  end
end