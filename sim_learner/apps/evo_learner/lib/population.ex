defmodule Population do
  defstruct [:entities, :gen]

  def new(entities) do
    %Population{entities: entities, gen: 0}
  end

  def next(entities, up_to) do
    # Get fittest from population
    trained_entities = EvoRunner.run_eval(entities)
    sorted = Enum.sort_by(trained_entities, fn entity -> entity.points end)
    |> Enum.reverse
    fittest = for i <- 0..up_to do
      Enum.at(sorted, i)
    end



    IO.puts("MAX: " <> Integer.to_string(Enum.at(fittest, 0).points))
    IO.puts("MIN: " <> Integer.to_string(Enum.at(sorted, length(sorted)-1).points))

    # Get average points
    sum = Enum.reduce(sorted, 0, fn entity, acc ->
      acc + entity.points
    end)

    IO.puts("Average: " <> Float.to_string(sum/length(sorted)))

    min = Integer.to_string(Enum.at(sorted, length(sorted)-1).points)
    max = Integer.to_string(Enum.at(fittest, 0).points)
    avg = Float.to_string(sum/length(sorted))

    # Average of each param
    avg_params = for i <- 0..length(Enum.at(fittest, 0).params)-1 do
      sum = Enum.reduce(fittest, 0, fn entity, acc ->
        acc + Enum.at(entity.params, i)
      end)
      Float.to_string(sum/up_to)
    end

    csv_string = Enum.reduce(avg_params, "", fn param, acc ->
      acc <> param <> ","
    end) <> "\n"

    
    File.write("data.csv", csv_string, [:append])

    # Create new population
    new_populus = for _ <- 0..length(trained_entities) do

      # Get fittest entities
      f1 = Enum.at(fittest, Enum.random(0..up_to))
      f2 = Enum.at(fittest, Enum.random(0..up_to))

      new_entity_param = mutate(crossover(f1.params, f2.params))

      %Entity{params: new_entity_param, points: 0}
    end
    gen = entities.gen

    %Population{entities: new_populus, gen: gen + 1}
  end

  def crossover(params1, params2) do
    # Iterate through params and randomly choose one of the two
    crossed = for i <- 0..length(params1)-1 do
      if Enum.random(0..1) == 0 do
        Enum.at(params1, i)
      else
        Enum.at(params2, i)
      end
    end
    crossed
  end

  def mutate(params) do
    # Set one param to a random value
    index = Enum.random(0..length(params)-1)
    List.replace_at(params, index, Enum.random(0..100))
    params
  end


end
