# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_record/userstamp/version'

Gem::Specification.new do |s|
  s.name = 'activerecord-userstamp'
  s.version = ActiveRecord::Userstamp::VERSION
  s.authors = ['Joel Low']
  s.email = ['joel@joelsplace.sg']

  s.summary = 'Adds magic creator and updater attributes to your ActiveRecord models.'
  s.description = 'This gem extends ActiveRecord::Base to add automatic updating of created_by and updated_by attributes of your models in much the same way that the ActiveRecord::Timestamp module updates created_(at/on) and updated_(at/on) attributes.'
  s.homepage = 'https://github.com/lowjoel/activerecord-userstamp'
  s.license  = 'MIT'

  s.files         = Dir['**/*']
  s.test_files    = Dir['{test,spec,features}/**/*']
  s.executables   = Dir['bin/*'].map { |f| File.basename(f) }
  s.require_paths = ['lib']

  if ENV['CI'] == 'true'
    rails_version =
      case ENV['RAILS_VERSION']
      when nil, ''
        '>= 4.1'
      else
        "~> #{ENV['RAILS_VERSION']}"
      end
  else
    rails_version = '>= 4.1'
  end

  s.add_dependency 'rails', rails_version

  s.add_development_dependency 'tzinfo-data' if RUBY_PLATFORM =~ /mswin|mingw/
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'rspec-rails', '>= 3.3'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'codeclimate-test-reporter'
  s.add_development_dependency 'sqlite3'
end
