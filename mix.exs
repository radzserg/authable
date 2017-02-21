defmodule Authable.Mixfile do
  use Mix.Project

  def project do
    [app: :authable,
     version: "0.7.0",
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     description: description(),
     package: package(),
     deps: deps(),
     docs: [extras: ["README.md"]]]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      mod: {Authable, []},
      applications: [:logger, :comeonin,
        :secure_random]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [          
      {:comeonin, "~> 3.0"},
      {:secure_random, "~> 0.5"},
      {:plug, "~> 1.0 or ~> 1.1 or ~> 1.2 or ~> 1.3"},
      {:poison, "~> 2.0 or ~> 2.1 or ~> 2.2 or ~> 3.0 or ~> 3.1"},
      {:ex_machina, "~> 1.0.2", only: :test},
      {:credo, "~> 0.5", only: [:dev, :test]},
      {:ex_doc, "~> 0.14", only: :dev}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_), do: ["lib", "web"]

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"]
    ]
  end

  defp description do
    """
    OAuth2 Provider implementation modules and helpers using `ecto` and
    `postgress` for any `elixir` application.
    """
  end

  defp package do
    [name: :authable,
     files: ["lib", "web", "priv", "mix.exs", "README.md"],
     maintainers: ["Mustafa Turan"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/mustafaturan/authable"}]
  end
end
