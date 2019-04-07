defmodule Pong.Repo do
  use Ecto.Repo,
    otp_app: :pong,
    adapter: Ecto.Adapters.Postgres
end
