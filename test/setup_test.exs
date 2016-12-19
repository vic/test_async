defmodule TestAsync.SetupTest.One do
  use ExUnit.CaseTemplate

  using do
    quote do
      import unquote(__MODULE__)
      setup :one
    end
  end

  def one(ctx), do: Map.put(ctx, :one, 1)
end

defmodule TestAsync.SetupTest.Two do
  use ExUnit.CaseTemplate

  using do
    quote do
      import unquote(__MODULE__)
      setup :two
    end
  end

  def two(ctx = %{one: one}), do: Map.put(ctx, :two, one * 2)
end

defmodule TestAsync.SetupTest do
  use ExUnit.Case, async: true
  use TestAsync do
    use TestAsync.SetupTest.One
    use TestAsync.SetupTest.Two
  end

  setup :three

  test "did setup in order", %{async: true, three: three} do
    assert 6 == three
  end

  def three(ctx = %{two: two}) do
    Map.put(ctx, :three, two * 3)
  end
end
