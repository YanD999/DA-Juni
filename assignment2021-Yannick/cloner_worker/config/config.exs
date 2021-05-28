import Config

config :cloner_worker,
  n_workers: 4,
  default_rate: 2

config :kafka_ex,
  brokers: [{"localhost", 9092}]
