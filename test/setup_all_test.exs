defmodule TestAsync.CallOnce do

  @moduledoc """
  A simple genserver that will fail
  if called more than once.

  Used to test that `setup_all` is
  called only once before two concurrent
  tests.
  """

  use GenServer

  def start do
    GenServer.start(__MODULE__, 0, [name: __MODULE__])
  end

  def stop do
    GenServer.stop(__MODULE__, :shutdown)
  end

  def once! do
    GenServer.call(__MODULE__, :next)
  end

  def handle_call(:next, _from, 0),
  do: {:reply, 1, 1}
  def handle_call(:next, _from, _),
  do: {:error, :already_called_once}
end
  

defmodule TestAsync.SetupAllTest do
  use ExUnit.Case
  use TestAsync

  alias TestAsync.CallOnce, as: Once
  Once.start

  setup_all context do
    on_exit &Once.stop/0
    context
    |> Map.put(:setup_pid, current())
    |> Map.put(:once, Once.once!())
  end

  def current, do: self()

  test "each test has own process", %{setup_pid: setup_id} do
    assert current() != setup_id
  end

  test "another process", %{setup_pid: setup_id} do
    assert current() != setup_id
  end
end