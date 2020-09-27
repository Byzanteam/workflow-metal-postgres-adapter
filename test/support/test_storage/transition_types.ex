defmodule TestStorage.TransitionTypes do
  @moduledoc false

  defmodule SplitTypeEnum do
    @moduledoc false

    use EnumBuilder, [:none, :and]
  end

  defmodule JoinTypeEnum do
    @moduledoc false

    use EnumBuilder, [:none, :and]
  end
end
