defmodule FourRings.Math64 do
  @moduledoc """
  Signed 64-bit wraparound arithmetic helpers.
  """

  import Bitwise

  @two_to_64 1 <<< 64
  @mask @two_to_64 - 1
  @sign_bit 1 <<< 63

  def wrap(value) when is_integer(value) do
    masked = band(value, @mask)

    if masked >= @sign_bit do
      masked - @two_to_64
    else
      masked
    end
  end

  def add(a, b), do: wrap(a + b)
  def mul(a, b), do: wrap(a * b)
end
