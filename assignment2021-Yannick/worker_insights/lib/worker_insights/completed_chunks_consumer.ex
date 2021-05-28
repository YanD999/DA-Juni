defmodule WorkerInsights.CompletedChunksConsumer do
  use GenServer
  use KafkaEx.GenConsumer

  require Logger

  alias AssignmentMessages.ClonedChunk
  alias KafkaEx.Protocol.Fetch.Message

  @this __MODULE__

  @time 1000

  def start_link(args \\ []) do
    Process.send_after(@this, :recall, @time)
    GenServer.start_link(@this, args, name: @this)
  end

  def init(args) do
    {:ok, %{}}
  end

  def handle_message_set(messages, state) do
    for %Message{value: message} <- messages do
      with {:ok, chunk} <- ClonedChunk.decode(message) do
        if chunk.chunk_result == :COMPLETE do
          Logger.info("task complete")
          GenServer.cast(@this, {:add, chunk})
        end
      end
    end
    {:async_commit, state}
  end


  def handle_cast({:add, chunk}, state) do
    until = DateTime.from_unix!(chunk.original_todo_chunk.until_unix_ts)
    from  = DateTime.from_unix!(chunk.original_todo_chunk.from_unix_ts)
    
    if Map.has_key?(state, chunk.original_todo_chunk.currency_pair) do
      # Map( pair, tuple{entries, time} )
      # update value
      # get value
      tuple = elem(Map.fetch(state, chunk.original_todo_chunk.currency_pair), 1)
      new_tuple = { elem(tuple, 0) + length(chunk.entries), elem(tuple, 1) + DateTime.diff(until, from) }
      # update tuple in map
      new_state = Map.replace(state, chunk.original_todo_chunk.currency_pair, new_tuple)
      # save map in state
      {:noreply, new_state}
    else
      # put key
      new_state = Map.put(state, chunk.original_todo_chunk.currency_pair, {length(chunk.entries), DateTime.diff(until, from)})
      # save map in state
      {:noreply, new_state}
    end
  end

  def handle_info(:recall, state) do
    Enum.each(state, fn {pair, tuple} ->

      days = Integer.floor_div(elem(tuple, 1), 24 * 3600)
      hours = Integer.floor_div(rem(elem(tuple, 1), 24 * 3600), 3600)
     
      seconds = rem(rem(elem(tuple, 1), (24 * 3600)), 3600)
      
      if days == 0 do # niet door days 0 delen
        Logger.info("| pair | entries/day | entries/hr | N entries | total time frame in days, hrs, seconds |")
        Logger.info("| #{pair} | #{elem(tuple, 0)} | #{Float.floor(elem(tuple, 0) / 24)} | #{elem(tuple, 0)} entries | #{days} days, #{hours} hrs, #{seconds} seconds |")
      else
        Logger.info("| pair | entries/day | entries/hr | N entries | total time frame in days, hrs, seconds |")
        Logger.info("| #{pair} | #{Integer.floor_div(elem(tuple, 0), days)} | #{Float.floor((elem(tuple, 0) / days) / 24)} | #{elem(tuple, 0)} entries | #{days} days, #{hours} hrs, #{seconds} seconds |")
      end
    end)
    Process.send_after(@this, :recall, @time)
    {:noreply, state}
  end
end
