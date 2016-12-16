defmodule TestAsync do

  @moduledoc """
  Turn test examples into async cases.

  #{File.read!(Path.expand("../README.md", __DIR__))}
  """

  alias __MODULE__.Callbacks

  @doc false
  defmacro __using__(do: body), do: Callbacks.using(body, __CALLER__)
  defmacro __using__([]), do: Callbacks.using(nil, __CALLER__)

  @doc false
  defmacro test(a), do: Callbacks.define([a])
  
  @doc false
  defmacro test(a, b), do: Callbacks.define([a, b])
  
  @doc false  
  defmacro test(a, b, c), do: Callbacks.define([a, b, c])

end
