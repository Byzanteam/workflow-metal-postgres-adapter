defmodule WorkflowMetalPostgresAdapterTest do
  use ExUnit.Case
  doctest WorkflowMetalPostgresAdapter

  test "greets the world" do
    assert WorkflowMetalPostgresAdapter.hello() == :world
  end
end
