defmodule MemoriesWeb.AlbumLive do
  use MemoriesWeb, :live_view

  def mount(%{"album_name" => album_name, "album_order" => "1"}, %{}, socket) do
    case Memories.Albums.get_album(album_name, "test") do
      {:error, error_message} ->
        {:ok, assign(socket, :error, error_message)}

      {:ok, album} ->
        {:ok, assign(socket, :album, album)}
    end
  end

  def mount(%{"album_name" => album_name}, %{}, socket) do
    case Memories.Albums.get_album(album_name, "test") do
      {:error, error_message} ->
        {:ok, assign(socket, :error, error_message)}

      {:ok, _album} ->
        {:ok,
         push_redirect(socket,
           to:
             Routes.live_path(
               socket,
               MemoriesWeb.AlbumLive,
               album_name,
               1,
               []
             )
         )}
    end
  end
end
