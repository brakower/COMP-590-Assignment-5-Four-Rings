defmodule FourRings.RoutingTest do
  use ExUnit.Case

  alias FourRings.Coordinator

  test "negative numbers go to neg ring" do
    assert Coordinator.route(-7) == :neg
  end

  test "zero goes to zero ring" do
    assert Coordinator.route(0) == :zero
  end

  test "positive even goes to pos_even ring" do
    assert Coordinator.route(2) == :pos_even
    assert Coordinator.route(100) == :pos_even
  end

  test "positive odd goes to pos_odd ring" do
    assert Coordinator.route(1) == :pos_odd
    assert Coordinator.route(101) == :pos_odd
  end
end
