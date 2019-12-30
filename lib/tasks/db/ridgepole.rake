# frozen_string_literal: true

namespace :db do
  config_file = 'config/database.yml'
  schema_file = 'db/schemas/Schemafile'

  desc 'apply Schemafile and update schema.rb'
  task apply: :environment do
    ENV['RAILS_ENV'] ||= 'development'
    ENV['ALLOW_DROP_TABLE'] ||= Rails.env.production? ? '0' : '1'
    ENV['ALLOW_REMOVE_COLUMN'] ||= Rails.env.production? ? '0' : '1'
    task_return = `ridgepole -E #{ENV['RAILS_ENV']} --diff #{config_file} #{schema_file}`
    column_condition = task_return.include?('remove_column') && ENV['ALLOW_REMOVE_COLUMN'] == '0'
    table_condition = task_return.include?('drop_table') && ENV['ALLOW_DROP_TABLE'] == '0'
    if column_condition || table_condition
      puts '[Warning]this task contains some risks: "remove_column" or "drop_table"'
    else
      sh "ridgepole -E #{ENV['RAILS_ENV']} -c #{config_file} --apply -f #{schema_file}"
      sh 'rake db:schema:dump'
    end
  end

  desc 'write Schemafile from db'
  task export: :environment do
    ENV['RAILS_ENV'] ||= 'development'
    sh "ridgepole -E #{ENV['RAILS_ENV']} -c #{config_file} --export --split --output #{schema_file}"
    sh 'rake db:schema:dump'
  end
end
