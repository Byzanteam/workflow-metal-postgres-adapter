defmodule WorkflowMetalPostgresAdapter.Schema.TransitionTypesForTestAndExample do
  @moduledoc false

  defmodule SplitType do
    @moduledoc false

    use EctoEnum,
      none: 0,
      and: 1
  end

  defmodule JoinType do
    @moduledoc false

    use EctoEnum,
      none: 0,
      and: 1
  end
end
