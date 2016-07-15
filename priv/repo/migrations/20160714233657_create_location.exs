defmodule PhoenixTracker.Repo.Migrations.CreateLocation do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :latitude, :float
      add :longitude, :float
      add :recorded_at, :datetime

      timestamps
    end

  end
end
