defmodule PhoenixTracker.Location do
  use PhoenixTracker.Web, :model

  schema "locations" do
    @primary_key {:id, :integer, []}
    field :latitude, :float
    field :longitude, :float
    field :recorded_at, Ecto.DateTime
    field :battery_state, :string
    field :summary, :string
    field :icon, :string
    field :temperature, :float
    field :humidity, :float
    field :visibility, :float
    field :wind_bearing, :float
    field :wind_speed, :float
    field :message_type, :string
    field :message_content, :string

    timestamps
  end

  @required_fields ~w(id latitude longitude recorded_at battery_state message_type)
  @optional_fields ~w(summary icon temperature humidity visibility wind_bearing wind_speed message_content)

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
