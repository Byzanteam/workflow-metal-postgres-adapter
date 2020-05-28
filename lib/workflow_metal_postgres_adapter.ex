defmodule WorkflowMetalPostgresAdapter do
  @moduledoc """
  Documentation for WorkflowMetalPostgresAdapter.
  """

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

  defdelegate create_workflow(adapter_meta, workflow_params), to: Workflow
  defdelegate fetch_workflow(adapter_meta, workflow_id), to: Workflow
  defdelegate delete_workflow(adapter_meta, workflow_id), to: Workflow

  defdelegate fetch_edge_places(adapter_meta, workflow_id), to: Place
  defdelegate fetch_places(adapter_meta, transition_id, arc_direction), to: Place

  defdelegate fetch_transition(adapter_meta, transition_id), to: Transition
  defdelegate fetch_transitions(adapter_meta, place_id, arc_direction), to: Transition

  defdelegate fetch_arcs(adapter_meta, arc_beginning, arc_direction), to: Arc

  defdelegate create_case(adapter_meta, case_params), to: Case
  defdelegate fetch_case(adapter_meta, case_id), to: Case
  defdelegate update_case(adapter_meta, case_id, update_case_params), to: Case

  defdelegate create_task(adapter_meta, task_params), to: Task
  defdelegate fetch_task(adapter_meta, task_id), to: Task
  defdelegate update_task(adapter_meta, task_id, update_task_params), to: Task

  defdelegate issue_token(adapter_meta, token_params), to: Token
  defdelegate lock_tokens(adapter_meta, token_ids, locked_by_task_id), to: Token
  defdelegate unlock_tokens(adapter_meta, locked_by_task_id), to: Token
  defdelegate consume_tokens(adapter_meta, locked_by_task_id), to: Token

  defdelegate create_workitem(adapter_meta, workitem_params), to: Workitem
  defdelegate fetch_workitem(adapter_meta, workitem_id), to: Workitem
  defdelegate fetch_workitems(adapter_meta, task_id), to: Workitem
  defdelegate update_workitem(adapter_meta, workitem_id, update_workitem_params), to: Workitem
end
