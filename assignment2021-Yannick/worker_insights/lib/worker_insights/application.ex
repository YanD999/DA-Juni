defmodule WorkerInsights.Application do

  use Application
  import Supervisor.Spec

  @consumer_group "chunk_consumer"
  @topic_finished_chunk "finished-chunks"

  @impl true
  def start(_type, _args) do
    consumer_group_opts = []
    finished_chunk_consumer = WorkerInsights.CompletedChunksConsumer

    children = [
      supervisor(
        KafkaEx.ConsumerGroup,
        [finished_chunk_consumer, @consumer_group, [@topic_finished_chunk], consumer_group_opts]
      ),
      {WorkerInsights.CompletedChunksConsumer, []}
    ]

    opts = [strategy: :one_for_one, name: WorkerInsights.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
