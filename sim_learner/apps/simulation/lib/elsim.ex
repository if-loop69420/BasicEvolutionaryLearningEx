defmodule Elsim do
  # Starts the whole thing with a dynamic supervisor
  use DynamicSupervisor

  def start_link(name) do
    {:ok, pid} = DynamicSupervisor.start_link(__MODULE__, 0, name: name)
    :global.register_name(name, pid)
    {:ok, pid}
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  # Starts a named simulation and adds it to dynamic supervision tree
  defp start_child(dynPID, name) do
    spec = %{id: MyWorker, start: {Simulation, :start_link, [name]}}
    pidder = case DynamicSupervisor.start_child(dynPID, spec) do
      {:ok, pid} -> pid
      {:error, pid} -> pid
    end

    :global.register_name(name, pidder)
  end

  def new_sim(dynPID,name) do
    existing_sim(name) || start_child(dynPID,name)
  end

  defp existing_sim(name) do
    case :global.whereis_name(name) do
      :undefined -> nil
      pid -> {:ok, pid}
    end
  end
end
