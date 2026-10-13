defmodule ElixirClicker.Game do
  @moduledoc """
  Pure game rules. Takes a `GameState`, returns a new one. No database, no web.
  """
  alias ElixirClicker.GameState

  @spec click(GameState.t()) :: GameState.t()
  def click(%GameState{sloc: sloc, currency: currency} = game) do
    %{game | sloc: sloc + 1, currency: currency + 1}
  end
end
