defmodule PhoenixTracker.Repo.Migrations.CreatePhoto do
  use Ecto.Migration

  def change do
    create table(:photos) do
      add :latitude, :float
      add :longitude, :float
      add :asset, :string

      timestamps()
    end

  end
end
