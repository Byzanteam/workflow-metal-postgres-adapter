defmodule WorkflowMetalPostgresAdapter.Schema.ExecutorType do
  use Ecto.Type

  def type, do: :string

  def cast(executor) when is_binary(executor) do
    {:ok, executor}
  end

  def cast(executor) when is_atom(executor) do
    {:ok, to_string(executor)}
  end

  def cast(_executor), do: :error

  def load(executor) when is_binary(executor) do
    {:ok, String.to_existing_atom(executor)}
  end

  def dump(executor) when is_atom(executor), do: {:ok, to_string(executor)}
  def dump(executor) when is_binary(executor), do: {:ok, executor}
  def dump(_), do: :error
end
