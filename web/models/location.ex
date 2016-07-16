defmodule PhoenixTracker.Location do
  use PhoenixTracker.Web, :model

  schema "locations" do
    @primary_key {:id, :integer, []}
    field :latitude, :float
    field :longitude, :float
    field :recorded_at, Ecto.DateTime
    field :battery_state, :string

    timestamps
  end

  @required_fields ~w(id latitude longitude recorded_at)
  @optional_fields ~w(battery_state)

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
