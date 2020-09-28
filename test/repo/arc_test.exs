defmodule WorkflowMetal.Storage.Adapters.Postgres.Repo.ArcTest do
  use WorkflowMetal.Storage.Adapters.Postgres.RepoCase

  alias WorkflowMetal.Storage.Adapters.Postgres.Repo.Arc

  describe "fetch_arcs/3" do
    setup :insert_workflow_schema

    test "success", %{associations_params: associations_params} do
      %{
        places: [start_place, yellow_place, _red_place, _green_place, _end_place],
        transitions: [
          init_transition,
          y2r_transition,
          _r2g_transition,
          g2y_transition,
          _will_end_transition
        ]
      } = associations_params

      %{id: start_place_id} = start_place
      %{id: yellow_place_id} = yellow_place
      %{id: init_transition_id} = init_transition
      %{id: y2r_transition_id} = y2r_transition
      %{id: g2y_transition_id} = g2y_transition

      assert {:ok, [arc]} = Arc.fetch_arcs(@config, {:transition, init_transition.id}, :in)

      assert match?(
               %{place_id: ^start_place_id, transition_id: ^init_transition_id, direction: :out},
               arc
             )

      assert {:ok, [arc]} = Arc.fetch_arcs(@config, {:transition, init_transition.id}, :out)

      assert match?(
               %{place_id: ^yellow_place_id, transition_id: ^init_transition_id, direction: :in},
               arc
             )

      assert {:ok, arcs} = Arc.fetch_arcs(@config, {:place, yellow_place.id}, :in)

      assert MapSet.new(arcs, & &1.transition_id) ===
               MapSet.new([init_transition_id, g2y_transition_id])

      Enum.each(arcs, fn a ->
        assert a.direction === :in
        assert a.place_id === yellow_place_id
      end)

      assert {:ok, [arc]} = Arc.fetch_arcs(@config, {:place, yellow_place.id}, :out)

      assert match?(
               %{place_id: ^yellow_place_id, transition_id: ^y2r_transition_id, direction: :out},
               arc
             )
    end
  end
end
