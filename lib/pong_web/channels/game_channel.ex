defmodule PongWeb.GameChannel do
  use Phoenix.Channel


  def join("game:" <> game_id, _message, socket) do
    if !Process.whereis(:game_loop) do
      pid = spawn_link(GameLoop, :start, [])
      Process.register(pid, :game_loop)
    end

    {:ok, Game.all, socket}
  end

  def handle_in("reset", _message, socket) do
    broadcast!(socket, "update", Game.reset)
  end

  def handle_in(event, %{"player" => whosplayin}, socket) do
    player = :"player_#{whosplayin}"

    case event do
      "move_up" -> Game.move_up(player)
      "move_down" -> Game.move_down(player)
    end

    broadcast!(socket, "update", %{player => Game.player(whosplayin)})
    {:noreply, socket}
  end
end
