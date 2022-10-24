defmodule ElixirClickerWeb.ClickerLive do
  use ElixirClickerWeb, :live_view
  alias ElixirClicker.{Repo, GameState}

  def mount(%{"id" => _} = _params, _session, socket) do
    {:ok, socket}
  end

  def mount(param, _session, socket) do
    {:ok,
     if connected?(socket) do
       :timer.send_interval(1000, self(), :calculate_employees_sloc)

       case Repo.insert(%GameState{currency: 0.0, sloc: 0}) do
         {:ok, game_state} ->
           socket = assign(socket, %{game: game_state, employees: employees()})
           push_redirect(socket, to: "/" <> game_state.id)

         {:error, _changeset} ->
           assign(socket, :error, "sorry")
       end
     else
       socket
     end}
  end

  def handle_params(%{"id" => id} = _params, _uri, socket) do
    game_state = Repo.get!(GameState, id)
    socket = assign(socket, %{game: game_state, employees: employees()})
    :timer.send_interval(1000, self(), :calculate_employees_sloc)
    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def employees() do
    [
      intern: %{"name" => "Intern", "locps" => 1, "multiplier" => 0, "count" => 1, "cost" => 100.0},
      junior: %{"name" => "Junior", "locps" => 5, "multiplier" => 0, "count" => 1, "cost" => 500.0},
      intermediate: %{"name" => "Intermediate", "locps" => 10, "multiplier" => 0, "count" => 1, "cost" => 1000.0},
      senior: %{"name" => "Senior", "locps" => 20, "multiplier" => 0, "count" => 1, "cost" => 4000.0},
      rockstar: %{"name" => "Rockstar", "locps" => 50, "multiplier" => 0, "count" => 1, "cost" => 10000.0},
      head: %{"name" => "Head of Engineering", "locps" => 0, "multiplier" => 2, "count" => 1, "cost" => 20000.0},
      doubleHead: %{"name" => "Hydra", "locps" => 0, "multiplier" => 4, "count" => 1, "cost" => 40000.0}
    ]
  end

  def handle_event("elixir_clicked", _, socket) do
    new_state =
      Ecto.Changeset.change(socket.assigns.game, %{
        sloc: socket.assigns.game.sloc + 1,
        currency: socket.assigns.game.currency + 1
      })

    game_state = Repo.update!(new_state)
    {:noreply, assign(socket, :game, game_state)}
  end

  def handle_event("employee_bought", %{"employee" => value}, socket) do
    {new_employee_state, new_currency_state} =
      case Map.fetch(socket.assigns.game.employee_state, value) do
        {:ok, current} ->
          if socket.assigns.game.currency >= current["cost"] do
            new_count = Map.update!(current, "count", &(&1 + 1))

            new_employee_state =
              Map.update!(socket.assigns.game.employee_state, value, fn _ -> new_count end)

            {new_employee_state, socket.assigns.game.currency - current["cost"]}
          else
            {socket.assigns.game.employee_state, socket.assigns.game.currency}
          end

        :error ->
          add_employee(value, socket)
      end

    new_state =
      Ecto.Changeset.change(socket.assigns.game, %{
        employee_state: new_employee_state,
        currency: new_currency_state
      })

    game_state = Repo.update!(new_state)
    {:noreply, assign(socket, :game, game_state)}
  end

  def handle_info(:calculate_employees_sloc, socket) do
    employee_state = socket.assigns.game.employee_state

    {game_state, locps} =
      unless Enum.empty?(employee_state) do
        new_sloc =
          Enum.reduce(employee_state, 0, fn {_, x}, acc ->
            acc + x["locps"] * x["count"]
          end)
        multiplier = Enum.reduce(employee_state, 0, fn {_, x}, acc ->
          acc + :math.pow(x["multiplier"], x["count"])
        end)

        new_state =
          Ecto.Changeset.change(socket.assigns.game, %{
            sloc: socket.assigns.game.sloc + new_sloc,
            currency: socket.assigns.game.currency + (new_sloc * max(multiplier, 1))
          })

        {Repo.update!(new_state), new_sloc}
      else
        {socket.assigns.game, 0}
      end

    {:noreply, assign(socket, %{game: game_state, locps: locps})}
  end

  def add_employee(employee_type, socket) do
    employees = socket.assigns.employees
    cost = employees[String.to_atom(employee_type)]["cost"]

    if socket.assigns.game.currency >= cost do
      new_employee =
        Map.put(
          socket.assigns.game.employee_state,
          employee_type,
          employees[String.to_atom(employee_type)]
        )

      new_currency = socket.assigns.game.currency - cost
      {new_employee, new_currency}
    else
      {socket.assigns.game.employee_state, socket.assigns.game.currency}
    end
  end
end
