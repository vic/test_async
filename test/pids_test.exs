defmodule TestAsync.PidsTest do

  use ExUnit.Case
  use TestAsync

  describe "pids" do
    @tag :one
    test "pid one", %{async: true} do
      self() |> IO.inspect
    end

    @tag :two
    test "pid two", %{async: true} do
      self() |> IO.inspect
    end
  end

end
