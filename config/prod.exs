use Mix.Config

config :pong, PongWeb.Endpoint,
  http: [port: System.get_env("PORT")],
  url: [scheme: "https", host: "phoenix-socket-pong", port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: Map.fetch!(System.get_env(), "SECRET_KEY_BASE")

# Do not print debug messages in production
config :logger, level: :info

# Database configurartion
config :pong, Pong.Repo,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true
