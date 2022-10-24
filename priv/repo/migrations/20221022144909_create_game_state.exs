defmodule ElixirClicker.Repo.Migrations.CreateGameState do
  use Ecto.Migration

  def change do
    create table(:game_state, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :sloc, :integer
      add :currency, :float

      timestamps()
    end
  end
end
