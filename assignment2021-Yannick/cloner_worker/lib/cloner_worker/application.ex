defmodule ClonerWorker.Application do
  use Application
  import Supervisor.Spec

  alias ClonerWorker.TodoChunkConsumer
  alias ClonerWorker.WorkerDynamicSupervisor

  @chunk_consumer "todo_chunks_consumer_group"
  @topic_todo_chunk "todo-chunks"

  @impl true
  def start(_type, _args) do
    consumer_group_opts = [{:auto_offset_reset, :latest}]
    gen_consumer_todo_chunk = ClonerWorker.TodoChunkConsumer

    children = [
      {ClonerWorker.WorkerDynamicSupervisor, []},
      {ClonerWorker.Queue, []},
      {ClonerWorker.WorkerManager, []},
      supervisor(
        Registry,
        [:unique, :my_registry]),
      supervisor(
        KafkaEx.ConsumerGroup,
        [gen_consumer_todo_chunk, @chunk_consumer, [@topic_todo_chunk], consumer_group_opts],
        id: TodoChunkConsumer
      ),
      {ClonerWorker.RateLimiter, []},
      {Task.Supervisor, name: ClonerWorker.TaskSupervisor}
    ]

    opts = [strategy: :one_for_one, name: ClonerWorker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
