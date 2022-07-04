defmodule Memories.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :name, :string, null: false
      add :content_type, :string, null: false

      add :signed_url, :text
      add :signed_url_expiration, :utc_datetime

      add :album_id, references(:albums, on_delete: :delete_all), null: false
      add :album_order, :integer, null: false

      timestamps()
    end

    create unique_index(:images, [:album_id, :name])
    create unique_index(:images, [:album_id, :album_order])
  end
end
