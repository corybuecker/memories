defmodule Memories.AlbumWorker do
  require Logger
  use GenServer

  @impl true
  def init(_) do
    {:ok, []}
  end

  @impl true
  def handle_call(:pop, _from, [head | tail]) do
    {:reply, head, tail}
  end

  @impl true
  def handle_cast({:push, element}, state) do
    {:noreply, [element | state]}
  end

  def fetch_images do
    Memories.Album
    |> Memories.Repo.all()
    |> Enum.flat_map(&fetch_images_for_album/1)
    |> Enum.each(&upsert_image/1)
  end

  defp fetch_images_for_album(%Memories.Album{prefix: prefix, id: id}) do
    {:ok, token} = Goth.fetch(Memories.Goth)
    conn = GoogleApi.Storage.V1.Connection.new(token.token)

    {:ok, response} =
      GoogleApi.Storage.V1.Api.Objects.storage_objects_list(conn, "bueckered-memories",
        prefix: prefix
      )

    response.items
    |> Enum.map_reduce(1, fn %GoogleApi.Storage.V1.Model.Object{
                               contentType: content_type,
                               name: name
                             },
                             acc ->
      {%{album_id: id, name: name, content_type: content_type, album_order: acc}, acc + 1}
    end)
    |> Tuple.to_list()
    |> List.first()
  end

  defp upsert_image(%{album_id: album_id, name: name} = changes) do
    case Memories.Repo.get_by(Memories.Image, name: name, album_id: album_id) do
      nil ->
        %Memories.Image{}

      image ->
        image
    end
    |> sign_url()
    |> Memories.Image.changeset(changes)
    |> Memories.Repo.insert_or_update!()
  end

  defp sign_url(%Memories.Image{} = image) do
    current_time = DateTime.utc_now() |> DateTime.truncate(:second)
    signed_url_expiration = current_time |> DateTime.add(86400, :second)
    current_timestamp = current_time |> DateTime.to_iso8601(:basic)

    Logger.debug(current_time)

    hostname = "storage.googleapis.com"
    path_to_resource = "/bueckered-memories/#{image.name}"

    query_strings =
      [
        "x-goog-signedheaders": "host",
        "x-goog-algorithm": "GOOG4-RSA-SHA256",
        "x-goog-credential":
          "texas-dev@bueckered-272522.iam.gserviceaccount.com/20220704/auto/storage/goog4_request",
        "x-goog-date": current_timestamp,
        "x-goog-expires": 86400,
        "content-type": image.content_type
      ]
      |> Enum.sort()

    presigned_uri = %URI{
      host: hostname,
      path: path_to_resource,
      query: URI.encode_query(query_strings),
      scheme: "https"
    }

    canonical_request =
      [
        "GET",
        path_to_resource,
        presigned_uri.query,
        "host:#{hostname}",
        "",
        "host",
        "UNSIGNED-PAYLOAD"
      ]
      |> Enum.join("\n")

    hashed_canonical_request =
      :crypto.hash(:sha256, canonical_request) |> Base.encode16() |> String.downcase()

    Logger.debug(canonical_request)
    Logger.debug(hashed_canonical_request)

    string_to_sign =
      [
        "GOOG4-RSA-SHA256",
        current_timestamp,
        "20220704/auto/storage/goog4_request",
        hashed_canonical_request
      ]
      |> Enum.join("\n")

    Logger.debug(string_to_sign)

    string_to_sign = string_to_sign |> Base.encode64()

    {:ok, token} = Goth.fetch(Memories.Goth)
    conn = GoogleApi.Storage.V1.Connection.new(token.token)

    {:ok, %GoogleApi.IAMCredentials.V1.Model.SignBlobResponse{signedBlob: signature}} =
      GoogleApi.IAMCredentials.V1.Api.Projects.iamcredentials_projects_service_accounts_sign_blob(
        conn,
        "-",
        "texas-dev@bueckered-272522.iam.gserviceaccount.com",
        body: %GoogleApi.IAMCredentials.V1.Model.SignBlobRequest{payload: string_to_sign}
      )

    reencoded_signature = signature |> Base.decode64!() |> Base.encode16() |> String.downcase()

    signed_query_strings = query_strings |> Keyword.merge("x-goog-signature": reencoded_signature)

    signed_uri = %URI{
      host: hostname,
      path: path_to_resource,
      scheme: "https",
      query: URI.encode_query(signed_query_strings)
    }

    image
    |> Memories.Image.changeset(%{
      signed_url: URI.to_string(signed_uri),
      signed_url_expiration: signed_url_expiration
    })
  end
end