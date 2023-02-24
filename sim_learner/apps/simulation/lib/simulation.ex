defmodule Simulation do
  use Agent
  use Task

  @bot_array [%Bot{id: 0,x: 0, y: 0, angle: 0, points: 0}]
  @field_array [%Field{x: 512, y: 512, type: :goal}]

  def start_link(instance, initial \\ %{bots: @bot_array, fields: @field_array}) do # Add fields array and move both bots and fields to map
    {:ok, pid} = Agent.start_link(fn -> initial end, name: instance)
    pid
  end

  def set_bot_cord(instance ,id, x, y) do
    random_field(instance)
    Agent.update(instance, fn map ->
      map = %{map | bots: Enum.map(map.bots, fn bot ->
        if bot.id == id do
          %Bot{id: bot.id, x: x, y: y, angle: bot.angle, points: bot.points}
        else
          bot
        end
      end)}
      map end
    )
    # Check if a bot could collect a ring. If so remove field and see if field was a goal ( if it was add 100 points to the bot)
    a = Task.async(fn ->
      fields = get_fields(instance);
      Enum.each(fields, fn field ->
        distance = :math.sqrt(:math.pow(field.x - x,2) + :math.pow(field.y - y,2))
        if distance < 36 do
          Agent.update(instance, fn map ->
            map = %{map | fields: Enum.filter(map.fields, fn ring ->
              # Filter out everything, that is not the field
              ring != field
            end)}
            map end
          )
          cond do
            #Normal goal
            field.type == :goal ->
              Agent.update(instance, fn map ->
                map = %{map | bots: Enum.map(map.bots, fn bot ->
                  if bot.id == id do
                    %Bot{bot | points: bot.points + 100}
                  else
                    bot
                  end
                end)}
                map end
              )
              Agent.update(instance, fn map ->
                map = %{map | fields: map.fields ++ [%Field{x: :rand.uniform(1024), y: :rand.uniform(1024), type: :goal}]}
                map end
              )
            #Oil spill. Turns bot randomly and sleeps
            field.type == :oil_spill ->
              set_bot_degree(instance, id, :rand.uniform(359))
            # Other items like double speed or points. I still need to think about how to implement those
            field.type == :teleporter ->
              x = :rand.uniform(1024)
              y = :rand.uniform(1024)
              set_bot_cord(instance, id,x,y)
          end
        end
      end)
    end)
    a
  end

  def set_bot_degree(instance ,id, angle) do
    random_field(instance)
    Agent.update(instance , fn map ->
      map = %{map | bots: Enum.map(map.bots, fn bot ->
        if bot.id == id do
          %Bot{id: bot.id, x: bot.x, y: bot.y, angle: angle, points: bot.points}
        else
          bot
        end
      end)}
      map end
    )
  end

  def get_bots(instance) do
    Agent.get(instance, fn map -> map.bots end)
  end

  def get_bot(instance,id) do
    Agent.get(instance, fn map ->
      Enum.find(map.bots, fn bot -> bot.id == id end)
    end)
  end

  def get_fields(instance) do
    Agent.get(instance, fn map -> map.fields end)
  end

  def stop_agent(instance) do
    _bots = get_bots(instance)
    Agent.stop(instance)
  end

  defp random_field(instance) do
    number = :rand.uniform(100)
    number_of_items = Enum.count(get_fields(instance))
    if (number <= 33 && number_of_items <= 4) do
      items = [:goal, :teleporter, :oil_spill]
      index = :rand.uniform(2)
      Agent.update(instance, fn map ->
        %{map | fields: map.fields ++ [%Field{x: :rand.uniform(1024), y: :rand.uniform(1024), type: Enum.at(items, index)}]}
      end)
    end
  end

end
