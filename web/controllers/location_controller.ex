defmodule PhoenixTracker.LocationController do
  use PhoenixTracker.Web, :controller
  alias PhoenixTracker.Location

  def index(conn, _params) do
    locations = Repo.all(Location)
    render(conn, "index.json", locations: locations)
  end
end
