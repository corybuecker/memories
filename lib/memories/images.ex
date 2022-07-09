defmodule Memories.Images do
  require Logger
  alias Memories.{Repo, Album, Image}
  import Ecto.Query, only: [from: 2]

  def get_image_from_album(prefix, key, album_order) do
    image_query =
      from i in Image,
        join: a in Album,
        on: a.id == i.album_id,
        where: i.album_order == ^album_order and a.prefix == ^prefix and a.key == ^key,
        preload: [:album]

    case image_query |> Repo.one() do
      nil ->
        {:error, "No album found"}

      album ->
        {:ok, album}
    end
  end
end
