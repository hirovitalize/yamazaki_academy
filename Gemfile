# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '~> 5.2.1.1'

gem 'bootsnap'
gem 'puma'

gem 'browserify-rails'
gem 'jquery-ui-rails'
gem 'sassc-rails'
gem 'uglifier', '>= 1.3.0'

gem 'mysql2'

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'rails-controller-testing'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'slim_lint'
  gem 'timecop'

  gem 'guard'
  gem 'guard-minitest'
  gem 'guard-rubocop'
  gem 'minitest-ar-assertions', require: 'minitest_activerecord_assertions'
  gem 'minitest-power_assert'
  gem 'minitest-stub_any_instance'
end

group :development do
  # debug
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'listen', '>= 3.0.5'
  gem 'rack-dev-mark'
  gem 'rack-mini-profiler', require: false
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # commands: i18n
  gem 'devise-i18n-views'
  gem 'easy_translate'
  gem 'i18n-debug'
  gem 'i18n-tasks', '~> 0.9.28'
  gem 'i18n_generators'

  # commands: analyze statically
  gem 'brakeman'
  gem 'bundler-audit'
  gem 'html2slim'
  gem 'license_finder'
  gem 'rails_best_practices'
  gem 'stackprof'

  # engines
  gem 'letter_opener_web' # mail viewer
  gem 'swagger_ui_engine' # API viewr
end

# queuing system
gem 'daemons'
gem 'delayed_job'
gem 'delayed_job_active_record'

# engines
gem 'delayed_job_web'
gem 'rails_db' # DB viewer and Sql executor

gem 'activerecord-session_store'
gem 'devise'
gem 'devise-encryptable'
gem 'pundit'

# api
gem 'grape'
gem 'grape-entity' # format json
gem 'grape-swagger'
gem 'grape-swagger-entity'

# model
gem 'aasm'
gem 'activerecord-import' # data import
gem 'activerecord-userstamp', path: './vendor/gem-local'
gem 'acts-as-taggable-on'
gem 'acts_as_list'
gem 'by_star' # 日付分析関連の便利scope群
gem 'draper'
gem 'enum_help'
gem 'paper_trail'
gem 'paper_trail-association_tracking'
gem 'paranoia', '~> 2.2'
gem 'validates_timeliness' # 日付のValidation

# view
gem 'cells'
gem 'cells-rails'
gem 'cells-slim'
gem 'cocoon'
gem 'data-confirm-modal'
gem 'font-awesome-rails'
gem 'icalendar'
gem 'kaminari'
gem 'ransack'
gem 'redcarpet'
gem 'simple_form'
gem 'slim'
gem 'slim-rails'

# configuration
gem 'config'
gem 'dotenv-rails'
gem 'seedbank'

# util
gem 'business_time'
gem 'geoip'
gem 'gon'
gem 'hashie'

# controller
gem 'responders' # configure default flashes and 'respond_to'

# cron
gem 'whenever', require: false

# db
gem 'ridgepole', '>= 0.7.2'

# ops
gem 'aws-ses'
gem 'newrelic_rpm'
gem 'rack-attack'
gem 'sentry-raven'
gem 'whiny_validation' # Validation Errorをログ出力

# commands: profiling
gem 'derailed_benchmarks'
gem 'memory_profiler'
