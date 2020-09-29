%Doctor.Config{
  ignore_modules: [],
  ignore_paths: [~r{lib/workflow_metal/storage/adapters/postgres/repo}],
  min_module_doc_coverage: 40,
  min_module_spec_coverage: 0,
  min_overall_doc_coverage: 100,
  min_overall_spec_coverage: 0,
  moduledoc_required: true,
  raise: false,
  reporter: Doctor.Reporters.Full
}
