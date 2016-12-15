defmodule App.NinjaTest do
  use ExUnit.Case

  use TestAsync do
    defp hidden, do: :ninja
  end

  test "can be seen" do
    assert hidden()
  end
end