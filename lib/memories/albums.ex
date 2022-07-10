defmodule Memories.Albums do
  import Ecto.Query, only: [from: 2]

  alias Memories.{Repo, Album}

  def authorized?(prefix, key) do
    album_query =
      from a in Album,
        where: a.prefix == ^prefix and a.key == ^key

    album_query |> Repo.exists?()
  end

  def get_album(key) do
    album_query =
      from a in Album,
        where: a.key == ^key

    case album_query |> Repo.one() do
      nil ->
        {:error, "No album found"}

      album ->
        {:ok, album}
    end
  end
end
