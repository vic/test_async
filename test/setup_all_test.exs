defmodule TestAsync.Inc do
  use GenServer

  def start do
    GenServer.start(__MODULE__, 0, [name: __MODULE__])
  end

  def stop do
    GenServer.stop(__MODULE__, :shutdown)
  end

  def next do
    GenServer.call(__MODULE__, :next)
  end

  def handle_call(:next, _from, n),
  do: {:reply, n + 1, n + 1}
end
  

defmodule TestAsync.SetupAllTest do
  use ExUnit.Case
  use TestAsync

  alias TestAsync.Inc
  Inc.start

  def once(context) do
    context
    |> Map.put(:setup_pid, current())
    |> Map.put(:once, Inc.next())
  end

  setup_all :once

  def current, do: self()

  test "each test has own process", %{setup_pid: setup_id, once: n, async: async} do
    assert async
    assert current() != setup_id
    assert n == 2
  end

  test "another process", %{setup_pid: setup_id, once: n, async: async} do
    assert async
    assert current() != setup_id
    assert n == 1
  end
end