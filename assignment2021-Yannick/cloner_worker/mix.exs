defmodule ClonerWorker.MixProject do
  use Mix.Project

  def project do
    [
      app: :cloner_worker,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ClonerWorker.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:assignment_messages, git: "https://github.com/distributed-applications-2021/assignment-messages", branch: "main"},
      {:kafka_ex, "~> 0.11.0"},
      {:jason, "~> 1.0"},
      {:tesla, "~> 1.2.1"},
    ]
  end
end
