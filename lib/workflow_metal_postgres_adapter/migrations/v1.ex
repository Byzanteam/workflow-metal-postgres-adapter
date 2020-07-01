defmodule WorkflowMetalPostgresAdapter.Migrations.V1 do
  @moduledoc """
  Init migration for WorkflowMetalPostgresAdapter.
  """
  use Ecto.Migration

  alias WorkflowMetalPostgresAdapter.Migrations.Helper

  def up(schema, prefix) do
    if schema != "public", do: execute("CREATE SCHEMA IF NOT EXISTS #{schema}")

    create_if_not_exists table("#{prefix}_workflows", primary_key: false) do
      add :id, :uuid, primary_key: true
      add :state, :integer, null: false
      add :metadata, :jsonb

      timestamps(updated_at: false)
    end

    create_if_not_exists index("#{prefix}_workflows", [:state])

    create_if_not_exists table("#{prefix}_places", primary_key: false) do
      add :id, :uuid, primary_key: true
      add :workflow_id, :uuid
      add :type, :integer, null: false
      add :metadata, :jsonb

      timestamps(updated_at: false)
    end

    create_if_not_exists index("#{prefix}_places", [:workflow_id, :type])

    create_if_not_exists table("#{prefix}_transitions", primary_key: false) do
      add :id, :uuid, primary_key: true
      add :workflow_id, :uuid
      add :join_type, :integer, null: false
      add :split_type, :integer, null: false
      add :executor, :string
      add :executor_params, :map
      add :metadata, :jsonb

      timestamps(updated_at: false)
    end

    create_if_not_exists index("#{prefix}_transitions", [:workflow_id])
    create_if_not_exists index("#{prefix}_transitions", [:join_type])
    create_if_not_exists index("#{prefix}_transitions", [:split_type])

    create_if_not_exists table("#{prefix}_arcs", primary_key: false) do
      add :id, :uuid, primary_key: true
      add :workflow_id, :uuid
      add :place_id, :uuid
      add :transition_id, :uuid
      add :direction, :integer, null: false
      add :metadata, :jsonb

      timestamps(updated_at: false)
    end

    create_if_not_exists index("#{prefix}_arcs", [:workflow_id, :direction])
    create_if_not_exists index("#{prefix}_arcs", [:place_id])
    create_if_not_exists index("#{prefix}_arcs", [:transition_id])

    create_if_not_exists table("#{prefix}_cases", primary_key: false) do
      add :id, :uuid, primary_key: true
      add :workflow_id, :uuid
      add :state, :integer, null: false

      timestamps()
    end

    create_if_not_exists index("#{prefix}_cases", [:workflow_id, :state])

    create_if_not_exists table("#{prefix}_tasks", primary_key: false) do
      add :id, :uuid, primary_key: true
      add :workflow_id, :uuid
      add :transition_id, :uuid
      add :case_id, :uuid
      add :state, :integer, null: false
      add :token_payload, :map

      timestamps()
    end

    create_if_not_exists index("#{prefix}_tasks", [:workflow_id, :state])
    create_if_not_exists index("#{prefix}_tasks", [:transition_id])
    create_if_not_exists index("#{prefix}_tasks", [:case_id])

    create_if_not_exists table("#{prefix}_tokens", primary_key: false) do
      add :id, :uuid, primary_key: true
      add :workflow_id, :uuid
      add :case_id, :uuid
      add :place_id, :uuid
      add :produced_by_task_id, :uuid
      add :locked_by_task_id, :uuid
      add :consumed_by_task_id, :uuid
      add :state, :integer, null: false
      add :payload, :map

      timestamps()
    end

    create_if_not_exists index("#{prefix}_tokens", [:workflow_id, :state])
    create_if_not_exists index("#{prefix}_tokens", [:case_id])
    create_if_not_exists index("#{prefix}_tokens", [:place_id])
    create_if_not_exists index("#{prefix}_tokens", [:locked_by_task_id])

    create_if_not_exists table("#{prefix}_workitems", primary_key: false) do
      add :id, :uuid, primary_key: true
      add :workflow_id, :uuid
      add :transition_id, :uuid
      add :case_id, :uuid
      add :task_id, :uuid
      add :state, :integer, null: false
      add :output, :map

      timestamps()
    end

    create_if_not_exists index("#{prefix}_workitems", [:workflow_id, :state])
    create_if_not_exists index("#{prefix}_workitems", [:transition_id])
    create_if_not_exists index("#{prefix}_workitems", [:case_id])
    create_if_not_exists index("#{prefix}_workitems", [:task_id])

    Helper.record_version(schema, prefix, 1)
  end

  def down(schema, prefix) do
    drop_if_exists table("#{prefix}_workflows", schema: schema)
    drop_if_exists table("#{prefix}_places", schema: schema)
    drop_if_exists table("#{prefix}_transitions", schema: schema)
    drop_if_exists table("#{prefix}_arcs", schema: schema)

    drop_if_exists table("#{prefix}_cases", schema: schema)
    drop_if_exists table("#{prefix}_tasks", schema: schema)
    drop_if_exists table("#{prefix}_tokens", schema: schema)
    drop_if_exists table("#{prefix}_workitems", schema: schema)
  end
end
