defmodule Director.TaskResultWaiter do
  use GenServer

  @this __MODULE__

  defstruct requests: %{}

  def start_link(args) do
    GenServer.start_link(@this, args, name: @this)
  end

  def init(_args) do
    {:ok, %@this{}}
  end

  def wait_for_response(task) do
    GenServer.call(@this, {:wait_response, task})
  end

  def register_response(task, response) do
    GenServer.cast(@this, {:register_response, task, response})
  end
 
  def handle_call({:wait_response, task}, state) do 
    {:noreply, nil}
  end

  def handle_cast({:register_response, task, response}, state) do 
    {:noreply, state}
  end
end