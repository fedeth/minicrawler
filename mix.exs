defmodule MiniCrawler.MixProject do
  use Mix.Project

  def project do
    [
      app: :mini_crawler,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:floki, "~> 0.31.0"},
      {:fast_html, "~> 2.0"},
      {:libgraph, "~> 0.7"}
    ]
  end
end
