defmodule TestAsync.PidsTest do
    
  use ExUnit.Case
  use TestAsync

  describe "pids" do
    @tag :one
    test "pid one" do
      self() |> IO.inspect
    end

    @tag :two
    test "pid two" do
      self() |> IO.inspect
    end
  end

end