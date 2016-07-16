defmodule PhoenixTracker.Repo.Migrations.AddBatteryStateToLocations do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add :battery_state, :string
    end
  end
end
