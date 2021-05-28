defmodule ChunkCreator.TodoTaskConsumer do
  use KafkaEx.GenConsumer

  alias KafkaEx.Protocol.Fetch.Message
  alias DatabaseInteraction.CurrencyPairContext
  alias DatabaseInteraction.TaskStatusContext
  alias DatabaseInteraction.TaskRemainingChunkContext
  alias AssignmentMessages.TodoTask
  alias ChunkCreator.TodoChunksKafkaContext

  def handle_message_set(messages, state) do
    for %Message{value: message} <- messages do
      {_, window_size} = Application.fetch_env(:chunk_creator, :max_window_size_in_sec)

      decoded = TodoTask.decode!(message)
      pair = CurrencyPairContext.get_pair_by_name(decoded.currency_pair)
      entries = TaskStatusContext.generate_chunk_windows(message.from_unix_ts, message.until_unix_ts, window_size)

      from = DateTime.from_unix!(message.from_unix_ts)
      until = DateTime.from_unix!(message.until_unix_ts)
        
      TaskStatusContext.create_full_task(%{from: from, until: until, uuid: message.task_uuid}, pair, entries)

      chunks = TaskRemainingChunkContext.get_all_unfinished_remaining_tasks_for_pair(pair)
      TodoChunksKafkaContext.task_remaining_chunk_to_produce_messages(chunks, pair.currency_pair)
      |> TodoChunksKafkaContext.produce_to_topics
    end
    {:async_commit, state}
  end
end
