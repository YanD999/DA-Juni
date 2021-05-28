defmodule ClonerWorker.RateLimiter do
  use GenServer

  @this __MODULE__

  @time 1000

  require Logger
 
  defstruct workers: [], rate: 0
  
  def start_link(args \\ []) do
    default_rate = Application.get_env(:cloner_worker, :default_rate)    
    GenServer.start_link(@this, %@this{rate: default_rate, workers: []}, name: @this)
  end

  def init(args) do
    Process.send_after(@this, :recall, @time)
    {:ok, args}
  end

  def handle_info(:recall, state) do
    Enum.each(0..(state.rate - 1), fn w ->
      if Enum.at(state.workers, w) do # als worker bestaat
        GenServer.cast(Enum.at(state.workers, w), :start_worker)
      end
    end)
    Process.send_after(@this, :recall, @time)
    {:noreply, %@this{workers: Enum.drop(state.workers, state.rate), rate: state.rate}}
  end

  def register(worker) do
    Logger.info("worker registered: #{worker} ")
    GenServer.cast(self(), {:add_worker, worker})
  end
  
  def handle_cast({:set_rate, new_rate}, state) do
    {:noreply, %@this{rate: new_rate, workers: state.workers}}
  end

  def handle_cast({:add_worker, worker}, state) do
    {:noreply, %@this{workers: [ state.workers | worker ], rate: state.rate}}
  end

  def set_rate(new_rate) do    
    GenServer.cast(self(), {:set_rate, new_rate})
  end
end
