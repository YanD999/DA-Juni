defmodule ChunkCreator.FinishedTasksKafkaContext do

  alias KafkaEx.Protocol.Produce.Request
  alias KafkaEx.Protocol.Produce.Message

  alias AssignmentMessages.TaskResponse

  @default_req %Request{
      topic: "finished-tasks",
      required_acks: 1
  }


  def create_task_response_produce_message(uuid, response) do
    binary = AssignmentMessages.encode_message!(%TaskResponse{task_result: response, todo_task_uuid: uuid})

    %Message{value: binary}
    |> produce_message
  end

  def produce_messages(messages) when is_list(messages), do: Enum.each(messages, fn message -> produce_message(message) end)

  def produce_message(message) do
    rq = %{@default_req | messages: [message]}
    KafkaEx.produce(rq)
  end
end
