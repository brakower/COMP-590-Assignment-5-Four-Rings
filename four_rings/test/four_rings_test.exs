defmodule FourRingsTest do
  use ExUnit.Case

  test "top-level helper exists" do
    assert is_function(&FourRings.run/2)
  end
end
