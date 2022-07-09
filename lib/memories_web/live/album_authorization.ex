defmodule MemoriesWeb.AlbumAuthorization do
  require Logger
  alias Memories.{Albums}

  import Phoenix.LiveView

  def on_mount(
        :default,
        %{"album_name" => album_name} = _params,
        %{"album_key" => album_key} = _session,
        socket
      ) do
    case Albums.authorized?(album_name, album_key) do
      false ->
        {:halt, push_redirect(socket, to: "/login")}

      true ->
        {:cont, socket |> assign(:album_key, album_key)}
    end
  end

  def on_mount(:default, _params, _session, socket) do
    {:halt, push_redirect(socket, to: "/login")}
  end
end
