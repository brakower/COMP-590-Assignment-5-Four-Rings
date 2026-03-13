defmodule FourRings.Math64Test do
  use ExUnit.Case

  alias FourRings.Math64

  test "wrap leaves small numbers alone" do
    assert Math64.wrap(5) == 5
    assert Math64.wrap(-5) == -5
  end

  test "signed 64-bit positive overflow wraps to negative" do
    max_i64 = 9_223_372_036_854_775_807
    assert Math64.add(max_i64, 1) == -9_223_372_036_854_775_808
  end

  test "signed 64-bit negative overflow wraps to positive" do
    min_i64 = -9_223_372_036_854_775_808
    assert Math64.add(min_i64, -1) == 9_223_372_036_854_775_807
  end
end
