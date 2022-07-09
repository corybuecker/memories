defmodule Memories.Albums do
  import Ecto.Query, only: [from: 2]

  alias Memories.{Repo, Album, Image}

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

  def get_album(prefix, key) do
    image_query = from i in Image, order_by: i.album_order, limit: 1

    album_query =
      from a in Album,
        where: a.prefix == ^prefix and a.key == ^key,
        preload: [images: ^image_query]

    case album_query |> Repo.one() do
      nil ->
        {:error, "No album found"}

      album ->
        {:ok, album}
    end
  end
end
