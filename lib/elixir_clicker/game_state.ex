defmodule ElixirClicker.GameState do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "game_state" do
    field :currency, :float
    field :sloc, :integer
    field :employee_state, :map, default: %{}

    timestamps()
  end

  @doc false
  def changeset(game_state, attrs) do
    game_state
    |> cast(attrs, [:sloc, :currency, :employee_state])
    |> validate_required([:sloc, :currency, :employee_state])
  end
end
