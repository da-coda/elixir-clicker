defmodule ElixirClickerWeb.ClickerLiveTest do
  use ElixirClickerWeb.ConnCase

  import Phoenix.LiveViewTest

  test "creates a game, redirects to it and counts clicks", %{conn: conn} do
    assert {:error, {:live_redirect, %{to: path}}} = live(conn, ~p"/")

    {:ok, view, html} = live(conn, path)
    assert html =~ ~r/>\s*0\s*<.*lines of code written/s

    assert view |> element("#write-code") |> render_click() =~ "$1<"
  end
end
