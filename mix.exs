defmodule TestAsync.Mixfile do
  use Mix.Project

  def project do
    [app: :test_async,
     version: "0.1.1",
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env),
     description: description(),
     package: package(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  def description do
    """
    Make tests inside your ExUnit case to run async.
    """
  end

  defp package do
    [files: ["lib", "mix.exs", "README*"],
     maintainers: ["Victor Borja"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/vic/test_async"}]
  end

end
