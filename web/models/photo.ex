defmodule PhoenixTracker.Photo do
  use PhoenixTracker.Web, :model
  use Arc.Ecto.Schema

  schema "photos" do
    field :latitude, :float
    field :longitude, :float
    field :asset, PhoenixTracker.Asset.Type

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:latitude, :longitude])
    |> cast_attachments(params, [:asset])
    |> validate_required([:latitude, :longitude, :asset])
  end
end
