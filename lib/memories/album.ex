defmodule Memories.Album do
  use Ecto.Schema
  import Ecto.Changeset

  schema "albums" do
    field :name, :string
    field :prefix, :string
    field :key, :string

    timestamps()
  end

  def changeset(album, params \\ %{}) do
    album
    |> cast(params, [:name, :prefix, :key])
    |> validate_required([:name, :prefix, :key])
  end
end
