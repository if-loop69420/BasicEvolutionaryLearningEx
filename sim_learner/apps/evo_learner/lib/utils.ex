defmodule EvoUtils do
  @moduledoc """
    Utility functions for the EvoLearner application
    Stuff like calculating the angle between two points
  """

  @doc """
    Calculates the angle between two points
    Returns an integer between 0 and 360
  """
  @spec angle(number, number, number, number) :: integer
  def angle(x1, y1, x2, y2) do
    rem(trunc(:math.atan2(y2 - y1, x2 - x1) * 180 / :math.pi) + 360, 360)
  end

  @doc """
    Calculates the distance between two points
  """
  @spec distance(number, number, number, number) :: number
  def distance(x,y,x1,y1) do
    abs :math.sqrt((:math.pow((x-x1),2))+(:math.pow((y-y1),2)))
  end
end
