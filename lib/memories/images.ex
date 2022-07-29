defmodule Memories.Images do
  require Logger
  alias Memories.{Repo, Album, Image, Redis}
  import Ecto.Query, only: [from: 2]

  def get_image_from_album(album_name, album_order) do
    album = from(a in Album, where: a.prefix == ^album_name, limit: 1) |> Repo.one()

    {:ok, images} =
      Redix.command(Redis, ["ZRANGE", "albums-#{album.id}", album_order, album_order])

    image_query =
      from i in Image,
        join: a in Album,
        on: a.id == i.album_id,
        where: a.id == ^album.id and i.name in ^images,
        preload: [:album],
        limit: 1

    image_query |> Repo.one()
  end
end
