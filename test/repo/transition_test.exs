defmodule WorkflowMetal.Storage.Adapters.Postgres.Repo.TransitionTest do
  use WorkflowMetal.Storage.Adapters.Postgres.RepoCase

  alias WorkflowMetal.Storage.Adapters.Postgres.Repo.Transition

  describe "fetch_transition/2" do
    setup :insert_workflow_schema

    test "success", %{associations_params: associations_params} do
      %{transitions: [start_transition | _]} = associations_params

      assert {:ok, start_transition_schema} =
               Transition.fetch_transition(@config, start_transition.id)

      assert start_transition_schema.id === start_transition.id
    end
  end

  describe "fetch_transitions/3" do
    setup :insert_workflow_schema

    test "success", %{associations_params: associations_params} do
      %{
        places: [_start_place, yellow_place, _red_place, _green_place, _end_place],
        transitions: [
          init_transition,
          y2r_transition,
          _r2g_transition,
          g2y_transition,
          _will_end_transition
        ]
      } = associations_params

      assert {:ok, transitions} = Transition.fetch_transitions(@config, yellow_place.id, :in)

      assert MapSet.new(transitions, & &1.id) ===
               MapSet.new([init_transition.id, g2y_transition.id])

      assert {:ok, [transition]} = Transition.fetch_transitions(@config, yellow_place.id, :out)
      assert transition.id === y2r_transition.id
    end
  end
end
