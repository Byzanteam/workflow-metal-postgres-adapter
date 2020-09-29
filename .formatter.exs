# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: [
    interface: 2,
    defaction: 1
  ],
  export: [
    locals_without_parens: [
      workflow_schema: 2,
      place_schema: 2,
      transition_schema: 3,
      arc_schema: 2,
      token_schema: 2,
      task_schema: 2,
      workitem_schema: 2
    ]
  ],
  import_deps: [
    :ecto,
    :ecto_sql
  ]
]
