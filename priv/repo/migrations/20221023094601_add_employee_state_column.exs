defmodule ElixirClicker.Repo.Migrations.AddEmployeeStateColumn do
  use Ecto.Migration

  def change do
    alter table(:game_state) do
      add :employee_state, :map, null: false, default: %{}
    end
  end
end
