defmodule WorkflowMetalPostgresAdapter do
  @moduledoc """
  Documentation for WorkflowMetalPostgresAdapter.
  """

  import WorkflowMetalPostgresAdapter.Utilities

  alias WorkflowMetalPostgresAdapter.Query.{
    Workflow,
    Place,
    Transition,
    Arc,
    Case,
    Task,
    Token,
    Workitem
  }

  def child_spec(_application, config) do
    repo = Keyword.fetch!(config, :repo)

    {:ok, nil, [repo: repo]}
  end

  interface Workflow, create_workflow: 2, fetch_workflow: 2, delete_workflow: 2

  interface Place, fetch_edge_places: 2, fetch_places: 3

  interface Transition, fetch_transition: 2, fetch_transitions: 3

  interface Arc, fetch_arcs: 3

  interface Case, create_case: 2, fetch_case: 2, update_case: 3

  interface Task, create_task: 2, fetch_task: 2, fetch_tasks: 3, update_task: 3

  interface Token,
    issue_token: 2,
    lock_tokens: 3,
    unlock_tokens: 2,
    consume_tokens: 2,
    fetch_tokens: 3

  interface Workitem,
    create_workitem: 2,
    fetch_workitem: 2,
    fetch_workitems: 2,
    update_workitem: 3
end
