defmodule Memories.Image do
  use Ecto.Schema
  import Ecto.Changeset

  schema "images" do
    field :name, :string
    field :content_type, :string

    field :signed_url, :string
    field :signed_url_expiration, :utc_datetime

    belongs_to :album, Memories.Album
    field :album_order, :integer

    timestamps()
  end

  def changeset(account, params \\ %{}) do
    account
    |> cast(params, [:name, :content_type, :signed_url, :signed_url_expiration, :album_order])
    |> validate_required([:name, :content_type, :album_order])
  end
end
