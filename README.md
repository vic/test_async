# TestAsync
<a href="https://travis-ci.org/vic/test_async"><img src="https://travis-ci.org/vic/test_async.svg"></a>

Make tests inside your ExUnit case to run async.

## Installation

[Available in Hex](https://hex.pm/package/test_async), the package can be installed
by adding `test_async` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:test_async, "~> 0.1.0", only: :test, runtime: false}]
end
```

## Intro

As you might already know, ExUnit lets you define async test cases by
providing an `async: true` option, like this:

```elixir
defmodule App.FineTest do
  use ExUnit.Case, async: true

  test "one" do
    IO.inspect :one
  end

  test "two" do
    IO.inspect :two
  end
end

defmodule App.OtherTest do
  use ExUnit.Case, async: true

  test "three" do
    IO.inspect :three
  end
end
```

As described by the [ExUnit documentation](https://hexdocs.pm/ex_unit/ExUnit.html) 


> `async: true`, runs the test case concurrently with other test cases. 
> The individual tests within each test case are still run serially

That means, `one` and `two` will still be run one after the other.

If you'd want those two to be run concurrently, you'd have to create
a new test case module for each.

This is exactly what `TestAsync` does, by providing a tiny macro `test`
macro that will turn your ExUnit case tests into async cases.

## Usage

Just `use TestAsync` !

```elixir
defmodule App.FineTest do
  use ExUnit.Case
  use TestAsync

  test "one" do
    IO.inspect :one
  end

  test "two" do
    IO.inspect :two
  end
end
```

[More examples as tests](https://github.com/vic/test_async/blob/master/test/)

## Gotchas

#### Current module

If you use `__MODULE__` on a test body, it will be the name of the
generated case module and not the one of the parent module.

```elixir
defmodule App.NamedTest do
  use ExUnit.Case

  test "one" do
    assert __MODULE__ == App.NamedTest.OneTest
  end
end
```

#### Setup functions

`setup` and `setup_all` are supported but only if they are given a
function name. And `setup_all` is run for every test instead of just
once as now every test was turned into its own test case.

#### Private functions 

Private functions defined on the parent module cannot be seen inside
the generated async modules.

```elixir
defmodule App.SomeTest do
  use ExUnit.Case
  use TestAsync

  defp hidden, do: :ninja

  test "cant be seen" do
    assert hidden() # compile error
  end
end
```

#### Shared case template

However you can give `use TestAsync` a `do` block, which will be
turned into a shared `ExUnit.CaseTemplate`.

```elixir
defmodule App.NinjaTest do
  use ExUnit.Case

  use TestAsync do
    defp hidden, do: :ninja
  end

  test "can be seen" do
    assert hidden()
  end
end
```
