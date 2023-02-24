defmodule EvoRunner do
  import EvalRunner

  # Gets a population and runs every entity through the evaluation in EvalRunner
  def run_eval(population) do
    gen = Integer.to_string(population.gen)
    IO.puts(gen)
    Elsim.start_link(String.to_atom("G" <> gen))
    handles = for index <- 0..length(population.entities)-1 do
      Task.async(fn -> EvalRunner.evaluate(Enum.at(population.entities, index), index, gen) end)
    end


    evaluated_entities = Enum.map(handles, fn handle ->
      Task.await(handle, :infinity)
    end)
    evaluated_entities
  end

end
