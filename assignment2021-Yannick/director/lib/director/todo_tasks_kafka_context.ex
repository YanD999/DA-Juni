defmodule Director.TodoTasksKafkaContext do
    alias KafkaEx.Protocol.Produce.Request
    alias KafkaEx.Protocol.Produce.Message

    alias Ecto.UUID

    alias AssignmentMessages.TodoTask

    @topic "todo-tasks"
  
    @default_req %Request{
      topic: @topic,
      required_acks: 1
    }

    def create_kafka_messages(messages, pair) do
        Enum.map(messages, fn mess -> create_kafka_message(mess, pair) end)
    end

    def create_kafka_message({from, until}, pair) do
        uuid = UUID.generate
    
        unix_from = DateTime.to_unix(from)
        unix_until =DateTime.to_unix(until)
    
        binary_data = AssignmentMessages.encode_message!(%TodoTask{task_operation: :ADD, currency_pair: pair, from_unix_ts: unix_from, until_unix_ts: unix_until, task_uuid: uuid})
        %Message{value: binary_data}
    end

    def produce_to_topic(message) when not is_list(message) do
        request = %{@default_req | messages: [message]}
        KafkaEx.produce(request)
    end

    def produce_to_topic(messages), do: Enum.map(messages, fn message -> produce_to_topic(message) end)
end
