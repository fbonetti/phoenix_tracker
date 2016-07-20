defmodule PhoenixTracker.Repo.Migrations.AddMessageFieldsToLocations do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add :message_type, :string
      add :message_content, :string
    end
  end
end
