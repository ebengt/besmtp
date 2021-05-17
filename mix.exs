defmodule Besmtp.Mixfile do
  use Mix.Project

  def project do
    [
      app: :besmtp,
      version: "0.1.0",
      elixir: "~> 1.9",
      escript: [main_module: Besmtp],
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mailman, "~> 0.4"}
    ]
  end
end
