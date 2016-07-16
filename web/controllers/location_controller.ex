defmodule PhoenixTracker.LocationController do
  use PhoenixTracker.Web, :controller
  alias PhoenixTracker.Location
  import Ecto.Query, only: [from: 2]

  def index(conn, _params) do
    query = from Location, order_by: [desc: :recorded_at]
    locations = Repo.all(query)
    render(conn, "index.json", locations: locations)
  end
end
