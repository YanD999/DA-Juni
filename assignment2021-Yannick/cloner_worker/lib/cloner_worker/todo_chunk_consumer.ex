defmodule ClonerWorker.TodoChunkConsumer do
  use KafkaEx.GenConsumer
  require Logger

  alias KafkaEx.Protocol.Fetch.Message
  alias AssignmentMessages.TodoChunk
  alias ClonerWorker.WorkerManager

  def handle_message_set(messages, state) do
    for %Message{value: message} <- messages do
      case TodoChunk.decode(message) do
        {:ok, chunk} ->
          WorkerManager.add_task(chunk)
          Logger.info("Chunk decoded")

        {:error, error} ->
          Logger.error("Decode chunk error: #{error}")
      end
    end
    {:async_commit, state}
  end

end
