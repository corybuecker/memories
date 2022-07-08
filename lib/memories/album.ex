defmodule Memories.Album do
  alias Memories.Image
  import Ecto.Changeset
  use Ecto.Schema

  schema "albums" do
    field :name, :string
    field :prefix, :string
    field :key, :string

    has_many :images, Image

    timestamps()
  end

  def changeset(album, params \\ %{}) do
    album
    |> cast(params, [:name, :prefix, :key])
    |> validate_required([:name, :prefix, :key])
  end
end
