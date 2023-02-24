defmodule EvoLearnerTest do
  use ExUnit.Case
  doctest EvoLearner

  test "greets the world" do
    assert EvoLearner.hello() == :world
  end
end
