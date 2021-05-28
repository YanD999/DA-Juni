defmodule Director do
  alias Director.TopicsKafkaContext
  alias Director.TodoTasksKafkaContext
  alias DatabaseInteraction.CurrencyPairContext
  alias DatabaseInteraction.CurrencyPairChunkContext

  def create_topics() do
    TopicsKafkaContext.create_topics()
  end

  def delete_topics() do
    TopicsKafkaContext.delete_topics()
  end

  def create_task(unix_from, unix_until, pair) do
    task = case CurrencyPairContext.get_pair_by_name(pair) do
      nil -> CurrencyPairContext.create_currency_pair(%{currency_pair: pair}) |> elem(1)

      _notnil -> CurrencyPairContext.get_pair_by_name(pair)
    end

    from = DateTime.from_unix!(unix_from)
    until = DateTime.from_unix!(unix_until)

    chunks = CurrencyPairChunkContext.generate_missing_chunks(from, until, task)

    TodoTasksKafkaContext.create_kafka_messages(chunks, pair)
    |> TodoTasksKafkaContext.produce_to_topic
  end

  def automatic_create_tasks() do
    {_, from } = Application.fetch_env(:director, :from)
    {_, until} = Application.fetch_env(:director, :until)
    {_, pairs} = Application.fetch_env(:director, :pairs_to_clone)
    Enum.each(pairs, fn pair -> create_task(from, until, pair) end)
  end
end
