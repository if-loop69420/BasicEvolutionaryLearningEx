defmodule Bot do
  @enforce_keys [:id, :x, :y, :angle, :points]
  defstruct [:id, :x, :y, :angle, :points]

  def pogdrive(x,y,angle,speed) do
    speed = rem(speed, 101)
    distance = speed / 100 * 8
    new_angle = rem(angle + 360, 360)
    alpha = new_angle

    ankathete = distance * :math.cos(alpha * :math.pi / 180)
    gkathete = distance * :math.sin(alpha * :math.pi / 180)

    {newx, newy} = {x + ankathete, y + gkathete}

    # Check if the new position is valid
    newx = cond do
      newx > 1024 -> 1024
      newx < 0 -> 0
      true -> newx
    end

    newy = cond do
      newy > 1024 -> 1024
      newy < 0 -> 0
      true -> newy
    end

    Process.sleep(5)
    {newx, newy}
  end

  def drive(x, y, angle, speed) do
    pogdrive(x,y,angle,speed)
  end

  def turn(angle, speed) do
    speed = cond do
      speed > 100 -> 100
      speed < -100 -> -100
      true -> speed
    end
    degrees = speed / 100 * 18
    new_angle = abs(rem(angle + round(degrees) +360, 360))
    Process.sleep(10)
    new_angle
  end

end
