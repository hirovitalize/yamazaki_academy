require_relative 'boot'

# use simple_form with ransack_form
ENV['RANSACK_FORM_BUILDER'] = '::SimpleForm::FormBuilder'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Coach2
  class Application < Rails::Application
    config.load_defaults 5.2

    config.i18n.default_locale = :ja
    config.i18n.available_locales = %i(ja en zh)
    config.i18n.enforce_available_locales = true
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]

    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local
    config.active_record.time_zone_aware_types = [:datetime]

    config.generators.template_engine = :slim
    config.browserify_rails.commandline_options = "-t babelify"

    config.active_job.queue_adapter = :delayed_job

    # 権限エラーで 403 を発生させる
    config.action_dispatch.rescue_responses = {
      "Pundit::NotAuthorizedError" => :forbidden
    }
  end
end
