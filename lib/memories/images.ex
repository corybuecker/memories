defmodule Memories.Images do
  require Logger
  alias Memories.{Repo, Album, Image, Redis}
  import Ecto.Query, only: [from: 2]

  def get_images_from_album(album_name, album_order) do
    {order, ""} = album_order |> Integer.parse()
    min = Kernel.max(0, order - 1)
    max = order + 1

    album = from(a in Album, where: a.prefix == ^album_name, limit: 1) |> Repo.one()

    {:ok, images} = Redix.command(Redis, ["ZRANGE", "albums-#{album.id}", min, max])

    image_query =
      from i in Image,
        join: a in Album,
        on: a.id == i.album_id,
        where: a.id == ^album.id and i.name in ^images,
        preload: [:album],
        limit: 3

    image_query |> Repo.all()
  end
end
