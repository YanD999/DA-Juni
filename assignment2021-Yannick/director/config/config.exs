import Config

config :director,
  pairs_to_clone: ["BTC_ETH", "USDT_BTC", "USDC_BTC"],
  from: 1_590_969_600,
  until: 1_591_500_000

config :director,
    ecto_repos: [Director.Repo]

config :director, Director.Repo,
    database: "assignmnent_crypto",
    username: "root",
    password: "t",
    hostname: "localhost"

config :assignment_messages,
    repo: Director.Repo

config :database_interaction,
    repo: Director.Repo

config :kafka_ex,
    brokers: [{"localhost", 9092}]
