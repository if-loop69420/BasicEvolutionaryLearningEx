defmodule SimulationTest do
  use ExUnit.Case
  @bot %Bot{id: 0, x: 0, y: 0, angle: 0, points: 0}


  test "Testing with 0 degrees" do
    {x,y} = Bot.drive(@bot.x,@bot.y,@bot.angle, 100)

    assert x == 8
    assert y == 0
  end

  test "Testing with 90 degrees" do
    bot = %Bot{id: 0, x: 0, y: 0, angle: 90, points: 0}
    {x,y} = Bot.drive(bot.x,bot.y,bot.angle, 100)

    assert x == 0
    assert y == 8
  end

  test "Testing with 180 degrees" do
    bot = %Bot{id: 0, x: 8, y: 0, angle: 180, points: 0}
    {x,y} = Bot.drive(bot.x,bot.y,bot.angle, 100)

    assert x == 0
    assert y == 0
  end

  test "Testing with 270 degrees" do
    bot = %Bot{id: 0, x: 0, y: 8, angle: 270, points: 0}
    {x,y} = Bot.drive(bot.x,bot.y,bot.angle, 100)

    assert x == 0
    assert y == 0
  end

  test "Testing with 45 degrees" do
    bot = %Bot{id: 0, x: 0, y: 0, angle: 45, points: 0}
    {x,y} = Bot.drive(bot.x,bot.y,bot.angle, 100)

    assert x >= 4
    assert y >= 4
  end
end
