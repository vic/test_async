defmodule TestAsync do

  @moduledoc """
  Turn test examples into async cases.

  #{File.read!(Path.expand("../README.md", __DIR__))}
  """

  @doc false
  defmacro __using__(do: body), do: __MODULE__.Callbacks.using(body, __CALLER__)
  defmacro __using__([]), do: __MODULE__.Callbacks.using(nil, __CALLER__)

  @doc false
  defmacro test(name, body) do
    quote do
      @async_tests unquote({name, body, Macro.Env.location(__CALLER__)} |> Macro.escape)
    end
  end

end
