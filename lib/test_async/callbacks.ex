defmodule TestAsync.Callbacks do
  @moduledoc false

  def using(template, env) do
    create_template(template, env)
    Module.register_attribute(env.module, :async_tests, accumulate: true, persist: true)
    quote do
      @after_compile unquote(__MODULE__)
      import ExUnit.Case, except: [test: 1, test: 2, test: 3]
      import TestAsync
    end
  end

  def define(args) do
    args = Macro.escape(args)
    quote do
      unquote(__MODULE__).register(unquote(args), __ENV__)
    end
  end


  def register(args = [name | _], env) do
    mod = env.module

    accumulates_attributes = [:tag, :describetag, :moduletag, :ex_unit_registered]
    accumulates = for k <- accumulates_attributes, do: {k, Module.get_attribute(mod, k)}

    additional_attributes = [:ex_unit_describe, :describetag, :ex_unit_setup, :ex_unit_setup_all]
    additional = for k <- additional_attributes, do: {k, Module.get_attribute(mod, k)}

    registered_attributes = Module.get_attribute(mod, :ex_unit_registered)
    registered = for(k <- registered_attributes, do: {k, Module.get_attribute(mod, k)})

    Enum.each [:tag | registered_attributes], fn(attribute) ->
      Module.delete_attribute(mod, attribute)
    end

    kw = [
      mod: mod,
      args: args,
      location: Macro.Env.location(env),
      registered: registered,
      additional: additional,
      accumulates: accumulates
    ]

    Module.put_attribute(mod, :async_tests, kw)

    name
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

  defp create_test(keyword, env) do
    args = [name | _] = Keyword.get(keyword, :args)
    registered = Keyword.get(keyword, :registered) |> Macro.escape
    additional = Keyword.get(keyword, :additional) |> Macro.escape
    accumulates = Keyword.get(keyword, :accumulates) |> Macro.escape
    location = Keyword.get(keyword, :location)

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

      for {k,vs} <- unquote(accumulates), v <- Enum.reverse(vs),
        do: Module.put_attribute(__MODULE__, k, v)

      for {k,v} <- unquote(additional),
        k != :ex_unit_setup_all && k != :ex_unit_setup,
        do: Module.put_attribute(__MODULE__, k, v)

      for {k,v} <- unquote(registered),
        do: Module.put_attribute(__MODULE__, k, v)

      for {k,v} <- unquote(additional),
        k == :ex_unit_setup_all || k == :ex_unit_setup,
        do: @ex_unit_setup (v ++ @ex_unit_setup)

      test(unquote_splicing(args))
    end
    # |> fn x -> IO.puts(Macro.to_string(x)); x end.()

    Module.create(mod_name, quoted, location)
    :ok
  end
end
