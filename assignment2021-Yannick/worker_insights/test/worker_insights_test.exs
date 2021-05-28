defmodule WorkerInsightsTest do
  use ExUnit.Case
  doctest WorkerInsights

  test "greets the world" do
    assert WorkerInsights.hello() == :world
  end
end
