defmodule PhoenixTracker.LocationTest do
  use PhoenixTracker.ModelCase

  alias PhoenixTracker.Location

  @valid_attrs %{latitude: "120.5", longitude: "120.5", recorded_at: "2010-04-17 14:00:00"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Location.changeset(%Location{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Location.changeset(%Location{}, @invalid_attrs)
    refute changeset.valid?
  end
end
