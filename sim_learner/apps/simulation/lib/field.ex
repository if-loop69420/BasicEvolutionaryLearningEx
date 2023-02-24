defmodule Field do
  @enforce_keys [:x,:y]
  defstruct [:x, :y, :type]
end