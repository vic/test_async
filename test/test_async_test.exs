
defmodule TestAsyncTest do

  use ExUnit.Case
  use TestAsync do
    def ninja, do: :black
  end

  def one, do: 1
  def two, do: 2

  def three(_ctx), do: {:ok, %{three: 3}}

  test "the truth" do
    assert one() + two() == 3
  end

  test "no setup here", ctx do
    assert nil == ctx[:three]
  end

  describe "math" do
    setup :three
    test "works", %{three: three} do
      assert one() + two() == three
    end

    @tag color: :black
    test "color", %{color: color} do
      assert color == :black
    end
  end

  describe "pids" do
    test "pid one" do
      self() |> IO.inspect
    end

    test "pid two" do
      self() |> IO.inspect
    end
  end

  describe "module names" do
    test "module name" do
      assert __MODULE__ == TestAsyncTest.ModuleNameTest
    end

    test "other name" do
      assert __MODULE__ == TestAsyncTest.OtherNameTest
    end
  end

end

defmodule App.NinjaTest do
  use ExUnit.Case

  use TestAsync do
    defp hidden, do: :ninja
  end

  test "can be seen" do
    assert hidden()
  end
end