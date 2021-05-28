defmodule ChunkCreator.Application do
  @moduledoc false

  use Application
  import Supervisor.Spec

  @task_consumer "todo_tasks_consumer_group"
  @chunk_consumer "finished_chunks_consumer_group"

  @topic_todo_tasks "todo-tasks"
  @topic_finished_chunks "finished-chunks"

  @impl true
  def start(_type, _args) do

    consumer_group_opts = []

    task_consumer_group = ChunkCreator.TodoTaskConsumer
    chunk_consumer_group = ChunkCreator.CompletedChunksConsumer

    topic_todo_tasks = [@topic_todo_tasks]
    topic_finished_chunks = [@topic_finished_chunks]

    children = [
      {ChunkCreator.Repo, []},
      supervisor(
        KafkaEx.ConsumerGroup,
        [task_consumer_group, @task_consumer, topic_todo_tasks, consumer_group_opts], id: :test
      ),
      supervisor(
        KafkaEx.ConsumerGroup,
        [chunk_consumer_group, @chunk_consumer, topic_finished_chunks, consumer_group_opts]
      )
    ]

    opts = [strategy: :one_for_one, name: ChunkCreator.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
