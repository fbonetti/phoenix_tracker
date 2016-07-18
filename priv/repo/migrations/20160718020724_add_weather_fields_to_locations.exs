defmodule PhoenixTracker.Repo.Migrations.AddWeatherFieldsToLocations do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add :summary, :string
      add :icon, :string
      add :temperature, :float
      add :humidity, :float
      add :visibility, :float
      add :wind_bearing, :float
      add :wind_speed, :float
    end
  end
end
