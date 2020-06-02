# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: [
    interface: 2
  ],
  import_deps: [
    :ecto_sql,
    :ecto_enum
  ]
]
