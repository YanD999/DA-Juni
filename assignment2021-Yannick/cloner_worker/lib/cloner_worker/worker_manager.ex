defmodule ClonerWorker.WorkerManager do
  use GenServer
  require Logger

  alias ClonerWorker.Queue
  alias ClonerWorker.WorkerDynamicSupervisor

  @this __MODULE__

  @time 1000

  
  defstruct workers: [] # alle workers

  def start_link(args \\ []) do
    GenServer.start_link(@this, args, name: WorkerManager)
  end

  def init(args) do
    WorkerDynamicSupervisor.create_workers()
    Process.send_after(@this, :recall, @time)
    {:ok, args}
  end

  def add_task(task) do
    GenServer.cast(@this, {:add_task, task})
  end

  def handle_cast({:add_task, task}, state) do
    Queue.add_to_queue(task)
    {:noreply, state}
  end

  def handle_cast({:add_new_worker, worker}, state) do
    {:noreply, %@this{workers: [state.workers | worker]}}
  end

  def handle_info(:recall, state) do
    available_workers = Enum.filter(state.list_all_workers, fn work -> GenServer.call(work, :available) end)
    Enum.each(available_workers, fn available ->
      task = Queue.get_first_element()
      if task do
        GenServer.cast(available, {:receive_task, task})
      end
    end)

    Process.send_after(@this, :recall, @time)
    {:noreply, state}
  end
end
