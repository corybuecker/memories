defmodule MemoriesWeb.AlbumLive do
  require Logger
  use MemoriesWeb, :live_view

  on_mount MemoriesWeb.AlbumAuthorization

  alias Memories.{Images, Image}

  def mount(
        %{"album_name" => album_name, "album_order" => album_order},
        _session,
        socket
      ) do
    case Images.get_image_from_album(
           album_name,
           album_order
         ) do
      nil ->
        {:ok, assign(socket, :error, "could not find images")}

      image = %Image{} ->
        {:ok,
         socket
         |> assign(:image, image)
         |> assign(:album_order, album_order |> String.to_integer())}
    end
  end

  def mount(%{"album_name" => album_name}, _session, socket) do
    {:ok,
     push_redirect(socket,
       to:
         Routes.live_path(
           socket,
           MemoriesWeb.AlbumLive,
           album_name,
           0,
           []
         )
     )}
  end

  def handle_params(%{"album_name" => album_name, "album_order" => album_order}, _link, socket) do
    case Images.get_image_from_album(
           album_name,
           album_order
         ) do
      nil ->
        {:noreply, assign(socket, :error, "could not find images")}

      image = %Image{} ->
        {:noreply,
         socket
         |> assign(:image, image)
         |> assign(:album_order, album_order |> String.to_integer())}
    end
  end
end
