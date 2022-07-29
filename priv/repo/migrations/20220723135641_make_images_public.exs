defmodule Memories.Repo.Migrations.MakeImagesPublic do
  use Ecto.Migration

  def up do
    execute """
      truncate table images;
    """

    alter table(:images) do
      remove :signed_url
      remove :signed_url_expiration

      add :public_url, :string, null: false
    end
  end

  def down do
    alter table(:images) do
      remove :public_url
      add :signed_url, :text
      add :signed_url_expiration, :utc_datetime
    end
  end
end
