defmodule Bullet.MixProject do
  use Mix.Project

  @name "Bullet"
  @source_url "https://github.com/okothkongo/Bullet"
  @version "0.1.0"
  def project do
    [
      app: :bullet,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      source_url: @source_url,
      homepage_url: @source_url,
      aliases: aliases(),
      deps: deps(),
      docs: docs(),
      package: package(),
      description: description(),
      preferred_cli_env: %{
        docs: :docs,
        "hex.publish": :docs,
        "hex.build": :docs,
        credo: :test
      }
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Bullet.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.29.1", only: :docs, runtime: false},
      {:credo, "~> 1.6", only: :test, runtime: false}
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      main: @name,
      source_ref: "v#{@version}"
    ]
  end

  defp package do
    [
      maintainers: ["Okoth Kongo"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp aliases do
    [
      credo: [
        "format",
        "format --check-formatted",
        "compile --warnings-as-errors --force",
        "credo --strict"
      ]
    ]
  end

  defp description do
    "WebSocket Library"
  end
end
