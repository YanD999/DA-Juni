defmodule ClonerWorker.Worker do
  use GenServer
  require Logger

  @this __MODULE__

  alias ClonerWorker.RateLimiter

  alias AssignmentMessages.ClonedEntry
  alias AssignmentMessages.ClonedChunk

  alias KafkaEx.Protocol.Produce.Message

  defstruct task: nil, free: True

  def start_link(args) do
    case args[:name] do
      nil ->
        Logger.error("Worker name doesn't exist")

      value ->
        Logger.debug("Worker #{value} has been created")
        GenServer.start_link(@this, args, name: {:via, Registry, {:my_registry, value}})
    end
  end

  def init(args) do
    GenServer.cast(WorkerManager, {:add_new_worker, self()})
    {:ok, args}
  end

  def handle_call({:receive_task, chunk}, _from, _state) do
    RateLimiter.register(self())
    {:reply, chunk, %@this{free: False, task: chunk}}
  end
  
  def handle_call(:available, _from, state) do
    {:reply, state.free, state}
  end

  def handle_cast(:start_worker, state) do
  Logger.info("start worker api")
    task = Task.Supervisor.async_nolink(ClonerWorker.TaskSupervisor, fn -> get_api(state.task) end)
    Task.await(task, 50000)
    {:noreply, %@this{task: nil, free: True}}
  end

  defp get_api(task) do
    query = [command: "returnTradeHistory",
             currencyPair: task.currency_pair,
             start: task.from_unix_ts,
             end: task.until_unix_ts
            ]
    case Tesla.get("https://poloniex.com/public", query: query) do
      {:ok, response} ->
        {:ok, list} = Jason.decode(response.body)

        if length(list) == 1000 do
          Logger.info("Window too big")
          window(task)
        else
          completed(list, task)
        end
      
      {:error, message} -> Logger.error("Error at worker: #{message}")
    end
  end

  defp window(task) do
    cloned_chunk = %ClonedChunk{
      chunk_result: :WINDOW_TOO_BIG,
      original_todo_chunk: task,
      entries: [],
      possible_error_message: " "
    }
    case AssignmentMessages.encode_message(cloned_chunk) do
      {:ok, message} ->
        %Message{value: message}

      {:error, message} ->
        Logger.debug("Error at encode: #{message}")
    end
  end

  defp completed(list, task) do
    entries = Enum.map(list, fn entry -> get_entry(entry) end)
    
    cloned_chunk = %ClonedChunk{
      chunk_result: :COMPLETE,
      original_todo_chunk: task,
      entries: entries,
      possible_error_message: " "
    }
    case AssignmentMessages.encode_message(cloned_chunk) do
      {:ok, message} ->
        %Message{value: message}

      {:error, message} ->
        Logger.debug("Error at encode: #{message}")
    end
  end

  defp get_entry(entry) do
    naive = NaiveDateTime.from_iso8601!(entry["date"])
    {:ok, datetime} = DateTime.from_naive(naive, "Etc/UTC")
    date = DateTime.to_unix(datetime)

    case entry["type"] do
      "sell" ->
        %ClonedEntry{
          trade_id: entry["globalTradeID"],
          date: date, type: :SELL, rate: entry["rate"],
          amount: entry["amount"], total: entry["total"]
        }

      "buy" ->
        %ClonedEntry{
          trade_id: entry["globalTradeID"],
          date: date, type: :BUY, rate: entry["rate"],
          amount: entry["amount"], total: entry["total"]
        }
    end
  end
end
