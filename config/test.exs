import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :memories, Memories.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "memories_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :memories, MemoriesWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "WvM6rBVUgwipDfMqp1BR3wvdZFVINyLFX0aJyuMJ/nP1J9xf0cMJtZw0p08MVgot",
  server: false

# In test we don't send emails.
config :memories, Memories.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
