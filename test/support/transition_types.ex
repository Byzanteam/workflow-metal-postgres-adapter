defmodule WorkflowMetalPostgresAdapter.Support.TransitionTypes do
  @moduledoc false

  defmodule SplitTypeEnum do
    @moduledoc false

    use EctoEnum,
      none: 0,
      and: 1
  end

  defmodule JoinTypeEnum do
    @moduledoc false

    use EctoEnum,
      none: 0,
      and: 1
  end
end
