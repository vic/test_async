defmodule TestAsync.Callbacks do
  def using(template, env) do
    create_template(template, env)
    quote do
      @after_compile unquote(__MODULE__)
      Module.register_attribute(unquote(env.module), :async_tests, accumulate: true, persist: true)
      import ExUnit.Case, except: [test: 2]
      import TestAsync
    end
  end

  def __after_compile__(env, _bytecode) do
    Module.get_attribute(env.module, :async_tests)
    |> Enum.map(&create_test(&1, env))
  end

  defp create_template(template, env) do
    mod_name = Module.concat(env.module, CaseTemplate)
    quoted = quote do
      use ExUnit.CaseTemplate
      using do
        unquote(template |> Macro.escape)
      end
    end
    Module.create(mod_name, quoted, Macro.Env.location(env))
    :ok
  end

  defp create_test({name, body}, env) do
    origin_module = env.module
    template_module = Module.concat(env.module, CaseTemplate)

    mod_name = 
      name
      |> String.replace(~r/[^\w\d]+/, "_")
      |> (&"#{&1}_test").()
      |> Macro.camelize

    mod_name = Module.concat(origin_module, mod_name)

    quoted = quote do
      use ExUnit.Case, async: true
      use unquote(template_module)
      import unquote(origin_module)
      test unquote(name), unquote(body)
    end

    Module.create(mod_name, quoted, Macro.Env.location(env))
    :ok
  end
end

defmodule TestAsync do

  @moduledoc """
  Documentation for TestAsync.
  """

  @doc false
  defmacro __using__(do: body), do: __MODULE__.Callbacks.using(body, __CALLER__)
  defmacro __using__([]), do: __MODULE__.Callbacks.using(nil, __CALLER__)

  defmacro test(name, body) do
    quote do
      @async_tests unquote({name, body} |> Macro.escape)
    end
  end

end
