defmodule ClonerWorker.WorkerDynamicSupervisor do
  use DynamicSupervisor

  @this __MODULE__

  def start_link(init_arg) do
    DynamicSupervisor.start_link(@this, init_arg, name: WorkerDynamicSupervisor)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def create_workers() do
    n_workers = 1..Application.get_env(:cloner_worker, :n_workers)
    workers = Enum.map(n_workers, fn w -> [name: String.to_atom("worker_#{w}"), n: w] end)
    for worker <- workers do
      DynamicSupervisor.start_child(WorkerDynamicSupervisor, {ClonerWorker.Worker, worker})
    end
  end
end
