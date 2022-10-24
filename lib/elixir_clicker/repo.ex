defmodule ElixirClicker.Repo do
  use Ecto.Repo,
    otp_app: :elixir_clicker,
    adapter: Ecto.Adapters.SQLite3
end
