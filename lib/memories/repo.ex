defmodule Memories.Repo do
  use Ecto.Repo,
    otp_app: :memories,
    adapter: Ecto.Adapters.Postgres
end
