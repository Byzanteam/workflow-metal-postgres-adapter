defmodule WorkflowMetalPostgresAdapter.Support.TransitionTypes do
  defmodule SplitTypeEnum do
    use EctoEnum,
      none: 0,
      and: 1
  end

  defmodule JoinTypeEnum do
    use EctoEnum,
      none: 0,
      and: 1
  end
end
