defmodule PhoenixTracker.LocationControllerTest do
  use PhoenixTracker.ConnCase

  alias PhoenixTracker.Location
  @valid_attrs %{latitude: "120.5", longitude: "120.5", recorded_at: "2010-04-17 14:00:00"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, location_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end
end
