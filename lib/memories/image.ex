defmodule Memories.Image do
  use Ecto.Schema
  import Ecto.Changeset

  schema "images" do
    field :name, :string
    field :content_type, :string
    field :public_url, :string

    belongs_to :album, Memories.Album

    timestamps()
  end

  def changeset(account, params \\ %{}) do
    account
    |> cast(params, [:name, :content_type, :public_url])
    |> validate_required([:name, :content_type, :public_url])
  end
end
