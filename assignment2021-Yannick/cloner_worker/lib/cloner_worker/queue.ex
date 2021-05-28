defmodule ClonerWorker.Queue do
  use GenServer

  @this __MODULE__

  defstruct queue: []

  def start_link(args \\ []) do
    GenServer.start_link(@this, %@this{}, name: Queue)
  end

  def init(args) do
    {:ok, args}
  end

  def add_to_queue(chunk) do
    GenServer.cast(self(), {:add_chunk, chunk}) 
  end

  def get_first_element() do
    GenServer.call(self(), :get_first) 
    drop_first_element()
  end

  def drop_first_element() do
    GenServer.cast(self(), :drop_first)
  end
  
  def handle_cast({:add_chunk, chunk}, state) do
    {:noreply, %@this{queue: [ state.queue | chunk ]}}
  end

  def handle_cast(:drop_first, state) do
    new = Enum.drop(state.queue, 1)
    {:noreply, %@this{queue: new}}
  end

  def handle_call(:get_first, state) do
    {:reply, Enum.at(state.queue, 0), state}
  end
end
