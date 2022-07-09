defmodule Memories.Repo.Migrations.CreateAlbums do
  use Ecto.Migration

  def change do
    create table(:albums) do
      add :name, :string, null: false
      add :prefix, :string, null: false
      add :key, :string, null: false

      timestamps()
    end

    create unique_index(:albums, [:prefix])
    create unique_index(:albums, [:key])
  end
end
