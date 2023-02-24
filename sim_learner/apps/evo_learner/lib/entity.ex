defmodule Entity do
  defstruct [:params, :points]

  def new(number) do
    params = for _ <- 1..number do
      Enum.random(0..100)
    end

    %Entity{params: params, points: 0}
  end
end
