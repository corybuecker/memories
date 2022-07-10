defmodule Memories.Repo.Migrations.RemoveAlbumOrder do
  use Ecto.Migration

  def up do
    drop(unique_index(:images, [:album_id, :album_order]))

    alter table(:images) do
      remove(:album_order, :album_order)
    end
  end

  def down do
    alter table(:images) do
      add :album_order, :integer, null: true
    end

    create unique_index(:images, [:album_id, :album_order])
  end
end
