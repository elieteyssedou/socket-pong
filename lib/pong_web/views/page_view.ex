alias Game.Position, as: Position

defmodule PongWeb.PageView do
  use PongWeb, :view

  def at_coord(x, y) do
    positions = generate_ball_positions(Game.ball.center) ++
      generate_player_positions(Game.player(1).center) ++
      generate_player_positions(Game.player(2).center)

    something = Enum.find(positions, fn(position) ->
      %Position{x: x, y: y} == position
    end)

    something
  end

  defp generate_ball_positions(position) do
    [position]
  end

  defp generate_player_positions(position) do
    [%Position{position | y: position.y - 1}, position, %Position{position | y: position.y + 1}]
  end
end
