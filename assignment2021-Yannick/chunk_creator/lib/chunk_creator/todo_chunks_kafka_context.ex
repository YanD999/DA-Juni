defmodule ChunkCreator.TodoChunksKafkaContext do
  alias KafkaEx.Protocol.Produce.Request
  alias DatabaseInteraction.TaskRemainingChunk
  alias AssignmentMessages.TodoChunk
  alias KafkaEx.Protocol.Produce.Message

  @default_req %Request{
      topic: "todo-chunks",
      required_acks: 1
  }


  def task_remaining_chunk_to_produce_message(%TaskRemainingChunk{} = task, pair) do
    from  = DateTime.to_unix(task.from)
    until = DateTime.to_unix(task.until)

    todo_chunk = %TodoChunk{currency_pair: pair, from_unix_ts: from, until_unix_ts: until, task_dbid: task.task_status_id}
    binary = AssignmentMessages.encode_message!(todo_chunk)
    %Message{value: binary}
  end

  def task_remaining_chunk_to_produce_messages(tasks, pair) when is_list(tasks) do 
    Enum.map(tasks, fn chunk -> task_remaining_chunk_to_produce_message(chunk, pair) end)
  end

  def produce_to_topics(messages) when is_list(messages), do: Enum.map(messages, fn message -> produce_to_topic(message) end)

  def produce_to_topic(message) do
    req = %{@default_req | messages: [message]}
    KafkaEx.produce(req)
  end
end
