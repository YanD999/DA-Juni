import Config

config :chunk_creator,
  max_window_size_in_sec: 1 * 1 * 60 * 60,
  ecto_repos: [ChunkCreator.Repo]

config :chunk_creator, ChunkCreator.Repo,
  database: "assignmnent_crypto",
  username: "root",
  password: "t",
  hostname: "localhost"

config :database_interaction,
  repo: ChunkCreator.Repo

config :kafka_ex,
  brokers: [{"localhost", 9092}]
