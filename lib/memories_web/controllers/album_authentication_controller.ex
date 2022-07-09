defmodule MemoriesWeb.AlbumAuthenticationController do
  require Logger
  use MemoriesWeb, :controller

  alias Memories.Albums

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def create(conn, %{"key" => album_key}) do
    case Albums.get_album(album_key) do
      {:error, _error_message} ->
        conn |> redirect(to: "/login")

      {:ok, album} ->
        conn
        |> put_session(:album_key, album.key)
        |> redirect(to: Routes.live_path(conn, MemoriesWeb.AlbumLive, album.prefix))
    end
  end
end
