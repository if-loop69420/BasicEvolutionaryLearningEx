defmodule Evolearn do
  @moduledoc """
  Create Entities with params and kick off the evolutional learning here.
  Check for how many Gens to go for and so on
  Maybe implement a mean function for plotting graphs
  """

  def start(n) do
    entities = for _ <- 0..n do
      Entity.new(5)
    end
    Population.new(entities);
  end

  def train_for(population, gens) do
    # Run the first generation
    train_for(population,gens,0)
  end

  def train_for(population, gens, current_gen) when gens > current_gen do
    # Run the next generation
    next_population = Population.next(population, 50)
    train_for(next_population, gens, current_gen + 1)
  end

  def train_for(population, gens,current_gen) when gens == current_gen do
    population
  end

end

# Maybe put a loop here, that uses start and so on for training
first_gen = Evolearn.start(100)

# Train for 100 gens
trained = Evolearn.train_for(first_gen, 12)

Enum.each(trained.entities, fn entity ->
  IO.inspect(entity)
end)