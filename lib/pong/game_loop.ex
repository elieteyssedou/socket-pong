alias Game.Position

defmodule GameLoop do
  def start(period \\ 60) do
    payload = %{}

    ball = Game.ball
    new_center = compute_new_center(ball, ball.vector)
    new_vector = compute_new_vector(ball, new_center)

    # player_2 scores
    payload = if round(new_center.x) <= 1 do
      Map.merge(payload, %{ player_2: %{ score: Game.increment_player_score(:player_2) } })
    else
      payload
    end

    # player_2 scores
    payload = if round(new_center.x) >= Game.size_x do
      Map.merge(payload, %{ player_1: %{ score: Game.increment_player_score(:player_1) } })
    else
      payload
    end

    Game.move_ball(new_center, new_vector)
    payload = Map.merge(payload, %{ ball: %{ center: Game.ball.center } })

    PongWeb.Endpoint.broadcast!("game:1", "update", payload)

    :timer.sleep(period)
    start(period)
  end

  defp compute_new_center(ball, vector) do
    new_x = ball.center.x + vector.x
    new_y = ball.center.y + vector.y

    new_x = cond do
      round(new_x) <= 1.0 ->
        1.0
      round(new_x) > Game.size_x ->
        Game.size_x
      true ->
        new_x
    end

    new_y = cond do
      round(new_y) <= 1.0 ->
        1.0
      round(new_y) > Game.size_y ->
        Game.size_y
      true ->
        new_y
    end

    %Position{ x: new_x, y: new_y }
  end

  defp compute_new_vector(ball, new_position) do
    new_vector_x = if round(new_position.x) <= 1 || round(new_position.x) >= Game.size_x || does_position_hit_player(new_position, ball.vector, :x) do
      -ball.vector.x
    else
      ball.vector.x
    end

    new_vector_y = if round(new_position.y) <= 1 || round(new_position.y) >= Game.size_y || does_position_hit_player(new_position, ball.vector, :y) do
      -ball.vector.y
    else
      ball.vector.y
    end

    %Position{ x: new_vector_x, y: new_vector_y }
  end

  defp does_position_hit_player(position, vector, axe) do
    player_1 = Game.player(1)
    player_2 = Game.player(2)

    hit = Enum.find(player_1.positions ++ player_2.positions, fn(pos) ->

      cond do
        axe == :x ->
          offset_x = pos.x + (if (vector.x > 0), do: -1, else: 1)
          Position.round(position) == %Position{pos | x: offset_x}
        axe == :y ->
          offset_y = pos.y + (if (vector.y > 0), do: -1, else: 1)
          Position.round(position) == %Position{pos | y: offset_y}
      end
    end)

    !!hit
  end
end
