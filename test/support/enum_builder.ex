defmodule EnumBuilder do
  @moduledoc false

  alias EctoEnum.Typespec

  defmacro __using__(keys) do
    quote bind_quoted: [keys: keys] do
      @behaviour Ecto.Type

      string_keys = Enum.map(keys, &Atom.to_string/1)

      pairs = Enum.zip(keys, string_keys)

      def type, do: :string

      for {key, value} <- pairs do
        def cast(unquote(key)), do: {:ok, unquote(key)}
        def cast(unquote(value)), do: {:ok, unquote(key)}
      end

      def cast(_other), do: :error

      for {key, value} <- pairs do
        def dump(unquote(key)), do: {:ok, unquote(value)}
        def dump(unquote(value)), do: {:ok, unquote(value)}
      end

      def dump(_term), do: :error

      def embed_as(_), do: :self

      def equal?(term1, term2), do: term1 === term2

      for {key, value} <- pairs do
        def load(unquote(value)), do: {:ok, unquote(key)}
      end
    end
  end
end
