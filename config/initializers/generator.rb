Coach2::Application.config.generators do |g|
  g.assets false
  g.helper false
  g.decorator false
  g.template_engine :slim
  g.orm :active_record, migration: false
  g.test_framework :test_unit,
    spec: true,
    fixture: false,
    view_specs: false,
    helper_specs: false,
    integration_tool: false
  g.system_tests nil
end

# Use the responders controller from the responders gem
Coach2::Application.config.app_generators.scaffold_controller :responders_controller
