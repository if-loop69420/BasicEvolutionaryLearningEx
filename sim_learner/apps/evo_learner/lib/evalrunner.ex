defmodule EvalRunner do
  @eval_length 15


  # Gets an Entity with list of params and runs an evaluation function
  def evaluate(entity, entity_num, gen) do
    # Run the evaluation function
    points = eval_function(entity.params, gen, entity_num)
    # Return the entity with the points
    %{entity | points: points}
  end

  defp eval_function(params, gen, num) do
    # TODO: Get a Simulation server started
    {:ok, supPID} = case :global.whereis_name(String.to_atom("G#{gen}")) do
      :undefined -> Elsim.start_link(String.to_atom("G#{gen}"))
      pid -> {:ok, pid}
    end

    name = String.to_atom("G#{gen}" <> " N" <> Integer.to_string num)
    Elsim.new_sim(supPID, name)
    _simPID = :global.whereis_name(name)

    # TODO: Program, that uses the params to run a Bot for 120s
    max_speed = Enum.at(params, 0)

    item_weights = for i <- 1..3 do
      Enum.at(params, i) / 100
    end

    do_reversing = Enum.at(params,4) > 50

    time = Time.utc_now

    run_game(max_speed, item_weights, do_reversing, time, name)

    # TODO: Kill the server and return the points
    bot = Simulation.get_bot(name,0)
    a = bot.points
    Simulation.stop_agent(name)
    a
  end

  defp run_game(max_speed, weights, rev,time, name) do
    now = Time.utc_now
    item_types = [:oil_spill, :teleporter, :goal]
    items_with_weights = Enum.zip(item_types, weights)
    |> Enum.into(%{})

    if (Time.diff(now,time,:second) < @eval_length) do
      bot = Simulation.get_bot(name,0)
      {x,y, angle} = {bot.x, bot.y, bot.angle}
      items = Simulation.get_fields(name)
      weighted_items = for i <- 0..length(items)-1 do
        item = Enum.at(items,i)
        weight = 2 - Map.get(items_with_weights,item.type)
        {item_x, item_y} = {item.x,item.y}
        score = weight * EvoUtils.distance(x,y,item_x,item_y)
        Map.put(Enum.at(items,i), :score, score)
      end

      goal = Enum.min_by(weighted_items, fn x -> x.score end)
      drive_to_goal(name,rev, max_speed, x,y,angle, goal,time)
      run_game(max_speed, weights, rev, time, name)
    end
  end

  def align(angle, rev, x,y, goal, name, time) when rev == true do
    if (Time.diff(Time.utc_now,time,:second) < @eval_length) do
      {g_x, g_y} = {goal.x,goal.y}
      slope= EvoUtils.angle(x,y,g_x,g_y)
      diff = angle - slope
      abs_diff = abs(diff)
      if(abs_diff > 90 && abs_diff < 270) do
        if(abs_diff < 182 && abs_diff > 178) do
          true
        else
          speed = cond do
            abs_diff >= 198 && abs_diff >= 162 -> 100
            true -> abs_diff / 18 * 100
          end

          na = cond do
            diff > 0 -> Bot.turn(angle,-speed)
            true -> Bot.turn(angle,speed)
          end

          Simulation.set_bot_degree(name,0, na)
          new_angle = Simulation.get_bot(name,0).angle
          align(new_angle, rev,x,y,goal,name,time)
        end
      else
        align(angle, false, x,y,goal,name, time)
      end
    else
      false
    end
  end

  # Aligns bot, for forward driving only.
  def align(angle, rev,x,y,goal,name, time) when rev == false do
    if(Time.diff(Time.utc_now, time, :second) < @eval_length ) do
      # get goal_x,y
      {g_x, g_y} = {goal.x,goal.y}
      # negative slope breaks everything
      slope = EvoUtils.angle(x,y,g_x,g_y)

      diff = angle - slope
      abs_diff = abs(diff)

      # cant always go speed 100 ofc, so need to calc how fast to go if angle < 18
      if abs_diff > 2 do
        speed = cond do
          abs_diff > 18 -> 100
          true -> abs_diff / 18 * 100
        end

        # IO.puts("Aligning, slope: #{slope}, angle: #{angle}, diff: #{abs_diff}, speed: #{speed}")

        # If angle is smaller than slope, turn right(angle gets bigger), else turn left (angle gets smaller)
        na = cond do
          diff > 0 -> Bot.turn(angle,-speed)
          true -> Bot.turn(angle,speed)
        end
        Simulation.set_bot_degree(name,0, na)

        new_angle = Simulation.get_bot(name, 0).angle
        align(new_angle, false, x,y,goal,name,time)
      else
        false
      end
    else
      false
    end
  end

  def drive_to_goal(name, can_rev, speed, x,y, angle, goal, time) do
    now = Time.utc_now

    if(EvoUtils.distance(x,y,goal.x,goal.y) > 36 && Time.diff(now,time,:second) < @eval_length) do
      has_to_go_rev = align(angle,can_rev, x,y,goal,name,time)

      if has_to_go_rev == true do
        {nx,ny} = Bot.drive(x,y,angle,-speed)
        Task.await(Simulation.set_bot_cord(name,0,nx,ny))
      else
        {nx,ny} = Bot.drive(x,y,angle,speed)
        Task.await(Simulation.set_bot_cord(name,0,nx,ny))
      end
      bot = Simulation.get_bot(name,0)
      {nx,ny,nangle} = {bot.x,bot.y, bot.angle}
      drive_to_goal(name,can_rev, speed,nx,ny,nangle, goal, time)
    end
  end
end
