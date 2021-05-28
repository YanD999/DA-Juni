defmodule Director.MixProject do
  use Mix.Project

  def project do
    [
      app: :director,
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
      mod: {Director.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:assignment_messages,  git: "https://github.com/distributed-applications-2021/assignment-messages", branch: "main"},
      {:database_interaction, git: "https://github.com/distributed-applications-2021/assignment-database-interaction", branch: "main"},
      {:myxql, "~> 0.4.3"},
      {:kafka_ex, "~> 0.11.0"}
    ]
  end
end
