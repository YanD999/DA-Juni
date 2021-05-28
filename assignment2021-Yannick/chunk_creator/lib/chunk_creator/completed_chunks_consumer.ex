defmodule ChunkCreator.CompletedChunksConsumer do
  use KafkaEx.GenConsumer
  require Logger
  require IEx

  alias KafkaEx.Protocol.Fetch.Message

  alias DatabaseInteraction.CurrencyPairChunkContext
  alias DatabaseInteraction.CurrencyPairContext
  alias DatabaseInteraction.TaskRemainingChunkContext
  alias DatabaseInteraction.TaskStatusContext

  alias AssignmentMessages.ClonedChunk


  def handle_message_set(messages, state) do
    for %Message{value: message} <- messages do
        chunk = ClonedChunk.decode!(message)
        id = (CurrencyPairContext.get_pair_by_name(chunk.original_todo_chunk.currency_pair)).id

        case chunk.chunk_result do
          :COMPLETE -> 
            taskremainingchunk = TaskRemainingChunkContext.get_chunk_by(id, chunk.original_todo_chunk.from_unix_ts, chunk.original_todo_chunk.until_unix_ts)
            TaskRemainingChunkContext.mark_as_done(chunk)
            CurrencyPairChunkContext.create_chunk_with_entries(taskremainingchunk, chunk.entries)
              case TaskStatusContext.task_status_complete?(id) do
                  {true, status} -> 
                    Logger.info(inspect("Complete"))
                    ChunkCreator.FinishedTasksKafkaContext.create_task_response_produce_message(status.uuid, chunk.chunk_result)
                    TaskStatusContext.delete_task_status(status)

                  {false,_,_} -> Logger.info(inspect("Not complete"))
              end

          :WINDOW_TOO_BIG -> 
            {first_chunk, second_chunk} = TaskRemainingChunkContext.halve_chunk(id, chunk.original_todo_chunk.from_unix_ts, chunk.original_todo_chunk.until_unix_ts)
            ChunkCreator.TodoChunksKafkaContext.task_remaining_chunk_to_produce_message(first_chunk, chunk.original_todo_chunk.currency_pair)
            |> ChunkCreator.TodoChunksKafkaContext.produce_to_topic

            ChunkCreator.TodoChunksKafkaContext.task_remaining_chunk_to_produce_message(second_chunk, chunk.original_todo_chunk.currency_pair)
            |> ChunkCreator.TodoChunksKafkaContext.produce_to_topic
        end
    end
    {:async_commit, state}
  end
end
