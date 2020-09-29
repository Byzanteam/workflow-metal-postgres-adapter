defmodule WorkflowMetalPostgresAdapter.Repo.Migrations.InitWorkflows do
  use Ecto.Migration

  @prefix "public"

  def up do
    create table("workflows", prefix: @prefix) do
      add :state, :string, null: false
      add :metadata, :map

      timestamps()
    end

    create index("workflows", [:state], prefix: @prefix)

    create table("places", prefix: @prefix) do
      add :type, :string, null: false
      add :metadata, :map

      add :workflow_id, references("workflows", prefix: @prefix, on_delete: :delete_all)

      timestamps()
    end

    create index("places", [:workflow_id, :type], prefix: @prefix)

    create table("transitions", prefix: @prefix) do
      add :join_type, :string, null: false
      add :split_type, :string, null: false
      add :executor, :string, null: false
      add :executor_params, :map
      add :metadata, :map

      add :workflow_id, references("workflows", prefix: @prefix, on_delete: :delete_all)

      timestamps()
    end

    create index("transitions", [:workflow_id], prefix: @prefix)

    create table("arcs", prefix: @prefix) do
      add :direction, :string, null: false
      add :metadata, :map

      add :place_id, references("places", prefix: @prefix, on_delete: :delete_all)
      add :transition_id, references("transitions", prefix: @prefix, on_delete: :delete_all)
      add :workflow_id, references("workflows", prefix: @prefix, on_delete: :delete_all)

      timestamps()
    end

    create index("arcs", [:workflow_id, :direction], prefix: @prefix)
    create index("arcs", [:place_id], prefix: @prefix)
    create index("arcs", [:transition_id], prefix: @prefix)

    create table("cases", prefix: @prefix) do
      add :state, :string, null: false

      add :workflow_id, references("workflows", prefix: @prefix, on_delete: :delete_all)

      timestamps()
    end

    create index("cases", [:workflow_id, :state], prefix: @prefix)

    create table("tasks", prefix: @prefix) do
      add :state, :string, null: false
      add :token_payload, :map

      add :workflow_id, references("workflows", prefix: @prefix, on_delete: :delete_all)
      add :transition_id, references("transitions", prefix: @prefix, on_delete: :delete_all)
      add :case_id, references("cases", prefix: @prefix, on_delete: :delete_all)

      timestamps()
    end

    create index("tasks", [:workflow_id, :case_id, :state], prefix: @prefix)

    create table("tokens", prefix: @prefix) do
      add :state, :string, null: false
      add :payload, :map

      add :produced_by_task_id, :uuid
      add :locked_by_task_id, :uuid
      add :consumed_by_task_id, :uuid

      add :workflow_id, references("workflows", prefix: @prefix, on_delete: :delete_all)
      add :place_id, references("places", prefix: @prefix, on_delete: :delete_all)
      add :transition_id, references("transitions", prefix: @prefix, on_delete: :delete_all)
      add :case_id, references("cases", prefix: @prefix, on_delete: :delete_all)

      timestamps()
    end

    create index("tokens", [:workflow_id, :case_id, :state], prefix: @prefix)

    create table("workitems", prefix: @prefix) do
      add :state, :string, null: false
      add :output, :map

      add :workflow_id, references("workflows", prefix: @prefix, on_delete: :delete_all)
      add :place_id, references("places", prefix: @prefix, on_delete: :delete_all)
      add :transition_id, references("transitions", prefix: @prefix, on_delete: :delete_all)
      add :case_id, references("cases", prefix: @prefix, on_delete: :delete_all)
      add :task_id, references("tasks", prefix: @prefix, on_delete: :delete_all)

      timestamps()
    end

    create index("workitems", [:workflow_id, :state], prefix: @prefix)
    create index("workitems", [:transition_id], prefix: @prefix)
    create index("workitems", [:case_id], prefix: @prefix)
    create index("workitems", [:task_id], prefix: @prefix)
  end

  def down do
    drop table("workflows", prefix: @prefix)
    drop table("places", prefix: @prefix)
    drop table("transitions", prefix: @prefix)
    drop table("arcs", prefix: @prefix)

    drop table("cases", prefix: @prefix)
    drop table("tasks", prefix: @prefix)
    drop table("tokens", prefix: @prefix)
    drop table("workitems", prefix: @prefix)
  end
end
