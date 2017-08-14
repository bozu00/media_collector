defmodule MediaCollector.Mixfile do
  use Mix.Project

  def project do
    [
      app: :media_collector,
      version: "0.1.0",
      elixir: "~> 1.5",
      # start_permanent: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      escript: [main_module: CLI],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger,:trot, :eex],
      # applications: [:logger,:trot,:eex],
      mod: {Crawler.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 0.7.2"},
      {:poison, "~> 3.1"},
      {:floki, "~> 0.18.0"},
      {:html_sanitize_ex, "~> 1.3.0-rc3"},
      {:qex, "~> 0.3"},
      {:trot, github: "hexedpackets/trot"}
    ]
  end
end
