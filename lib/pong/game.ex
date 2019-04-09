defmodule Game do
  use Agent

  @size_x 41
  @size_y 21

  defmodule Position do
    @derive Jason.Encoder
    @enforce_keys [:x, :y]
    defstruct [:x, :y]

    def round(position) do
      %Position{x: Kernel.round(position.x), y: Kernel.round(position.y)}
    end
  end

  def start_link do
    Agent.start_link(&new_game/0, name: __MODULE__)
  end

  def reset do
    Agent.get_and_update(__MODULE__, fn _state ->
      game = new_game()
      {game, game}
    end)
  end

  def all do
    Agent.get(__MODULE__, & &1)
  end

  def size_x do
    Agent.get(__MODULE__, & &1[:size_x])
  end

  def size_y do
    Agent.get(__MODULE__, & &1[:size_y])
  end

  def ball do
    Agent.get(__MODULE__, & &1[:ball])
  end

  def player(n) when is_integer(n) do
    Agent.get(__MODULE__, & &1[:"player_#{n}"])
  end

  def player(player) when is_atom(player) do
    Agent.get(__MODULE__, & &1[player])
  end

  def increment_player_score(player) do
    Agent.get_and_update(__MODULE__, fn(state) ->
      new_score = state[player][:score] + 1
      {new_score, put_in(state, [player, :score], new_score)}
    end)
  end

  def move_ball(new_center, new_vector) do
    Agent.update(__MODULE__, fn(state) ->
      state = put_in(state, [:ball, :center], new_center)
      put_in(state, [:ball, :vector], new_vector)
    end)
  end

  def move_up(player_name) do
    player_obj = player(player_name)
    new_center = %Position{player_obj.center | y: player_obj.center.y - 1}
    update_player_center(player_name, player_obj, new_center)
  end

  def move_down(player_name) do
    player_obj = player(player_name)
    new_center = %Position{player_obj.center | y: player_obj.center.y + 1}
    update_player_center(player_name, player_obj, new_center)
  end

  defp valid_positions(positions) do
    size_x = size_x()
    size_y = size_y()

    invalid_pos = Enum.find(positions, fn(pos) ->
      pos.x <= 0 || pos.x > size_x ||
        pos.y <= 0 || pos.y > size_y
    end)

    !(invalid_pos)
  end

  defp update_player_center(player_name, player_obj, new_center) do
    positions = compute_positions(new_center, player_obj.size_x, player_obj.size_y)

    if valid_positions(positions) do
      Agent.update(__MODULE__, fn(state) ->
        state = put_in(state, [player_name, :center], new_center)
        put_in(state, [player_name, :positions], positions)
      end)
    end
  end

  defp compute_positions(center, size_x, size_y) do
    Enum.reduce(0..(size_y - 1), [], fn(sizer_y, pos_acc) ->
      Enum.reduce(0..(size_x - 1), pos_acc, fn(sizer_x, pos_acc) ->
        new_x = center.x - size_x + Kernel.ceil(size_x / 2) + sizer_x
        new_y = center.y - size_y + Kernel.ceil(size_y / 2) + sizer_y

        [%Position{ x: new_x, y: new_y } | pos_acc]
      end)
    end)
  end

  defp new_game do
    ball_x_direction = if (:rand.uniform(2) == 1), do: 1, else: -1
    ball_y_direction = if (:rand.uniform(2) == 1), do: 1, else: -1
    ball_vector_y = (:rand.uniform(700) / 1000) * ball_y_direction
    ball_vector = %Position{x: 1.0 * ball_x_direction, y: ball_vector_y}
    ball_center = %Position{x: Kernel.ceil(@size_x / 2), y: Kernel.ceil(@size_y / 2)}

    player_size_x = 2
    player_size_y = 5

    player_1_center = %Position{x: 4, y: Kernel.ceil(@size_y / 2)}
    player_1_positions = compute_positions(player_1_center, player_size_x, player_size_y)

    player_2_center = %Position{x: @size_x - 2, y: Kernel.ceil(@size_y / 2)}
    player_2_positions = compute_positions(player_2_center, player_size_x, player_size_y)

    %{
      size_x: @size_x,
      size_y: @size_y,
      ball: %{
        vector: ball_vector,
        center: ball_center
      },
      player_1: %{
        score: 0,
        size_x: player_size_x,
        size_y: player_size_y,
        positions: player_1_positions,
        center: player_1_center
      },
      player_2: %{
        score: 0,
        size_x: player_size_x,
        size_y: player_size_y,
        positions: player_2_positions,
        center: player_2_center
      }
    }
  end
end
