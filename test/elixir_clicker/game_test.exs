defmodule ElixirClicker.GameTest do
  use ExUnit.Case, async: true

  alias ElixirClicker.{Game, GameState}

  describe "click/1" do
    test "adds one line of code and one dollar" do
      game = %GameState{sloc: 0, currency: 0.0}
      assert %GameState{sloc: 1, currency: 1.0} = Game.click(game)
    end
  end
end
