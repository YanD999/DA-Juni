defmodule Director.Application do

    use Application
    import Supervisor.Spec

    @consumer_group "task_consumer"
    @topic_finished_tasks "finished-tasks"

    @impl true
    def start(_type, _args) do
        consumer_group_opts = []
        fin_task_consumer = Director.FinishedTaskConsumer

        children = [
            Director.Repo,
            {Director.TaskResultWaiter, []},

            supervisor(
                KafkaEx.ConsumerGroup,
                [fin_task_consumer, @consumer_group, [@topic_finished_tasks], consumer_group_opts]
            )
        ]

        opts = [strategy: :one_for_one, name: Director.Supervisor]
        Supervisor.start_link(children, opts)
    end
end
