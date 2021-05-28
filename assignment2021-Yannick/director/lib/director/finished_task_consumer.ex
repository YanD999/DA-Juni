defmodule Director.FinishedTaskConsumer do
    use KafkaEx.GenConsumer

    require Logger

    alias KafkaEx.Protocol.Fetch.Message
    alias AssignmentMessages.TaskResponse

    def handle_message_set(messages, state) do
        for %Message{value: message} <- messages do
            decoded = TaskResponse.decode(message)

            case decoded.task_result do
              :TASK_CONFLICT -> Logger.info("There is a task conflict for task #{decoded.todo_task_uuid}")

              :COMPLETE -> Logger.info("The following task has been completed: #{decoded.todo_task_uuid}")
            end
          end
        {:async_commit, state}
    end
end
