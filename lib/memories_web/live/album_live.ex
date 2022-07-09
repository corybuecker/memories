defmodule MemoriesWeb.AlbumLive do
  require Logger
  use MemoriesWeb, :live_view

  on_mount MemoriesWeb.AlbumAuthorization

  alias Memories.{Images, Albums}

  def mount(
        %{"album_name" => album_name, "album_order" => "1"},
        %{"album_key" => album_key},
        socket
      ) do
    case Images.get_image_from_album(album_name, album_key, 1) do
      {:error, error_message} ->
        {:ok, assign(socket, :error, error_message)}

      {:ok, image} ->
        {:ok, assign(socket, :image, image)}
    end
  end

  def mount(%{"album_name" => album_name}, %{"album_key" => album_key}, socket) do
    case Albums.get_album(album_name, album_key) do
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

  def handle_params(%{"album_name" => album_name, "album_order" => album_order}, _link, socket) do
    case Images.get_image_from_album(
           album_name,
           socket.assigns |> Map.get(:album_key),
           album_order
         ) do
      {:error, error_message} ->
        {:noreply, assign(socket, :error, error_message)}

      {:ok, image} ->
        {:noreply, assign(socket, :image, image)}
    end
  end
end
