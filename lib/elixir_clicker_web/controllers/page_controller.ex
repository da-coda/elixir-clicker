defmodule ElixirClickerWeb.PageController do
  use ElixirClickerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
