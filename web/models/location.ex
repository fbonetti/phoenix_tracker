defmodule PhoenixTracker.Location do
  use PhoenixTracker.Web, :model

  schema "locations" do
    field :latitude, :float
    field :longitude, :float
    field :recorded_at, Ecto.DateTime

    timestamps
  end

  @required_fields ~w(latitude longitude recorded_at)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
