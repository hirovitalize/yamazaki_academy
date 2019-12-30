# frozen_string_literal: true

require('./lib/tasks/task_util.rb')
Dir[File.dirname(__FILE__) + '/converts/*.rb'].each { |file| require file }

namespace :db do
  # ENV['TABLE'] target (old)table. ALL if empty
  desc 'convert from old schema to new tables'
  task convert: :environment do
    ::TaskUtil.profile do
      PaperTrail.enabled = false
      puts "Start converting #{ENV['SCRIPT'].presence || 'ALL'} tables from schema: #{Tasks::Db::Converts::AbstractConvert.new.src_schema}."

      extract_convert_classes(ENV['SCRIPT']).each do |script|
        puts "#{script}..."
        clear_and_run script
      end

      puts "Finish converting #{ENV['SCRIPT'].presence || 'ALL'} tables from schema: #{Tasks::Db::Converts::AbstractConvert.new.src_schema}."
      PaperTrail.enabled = true
    end
  end

  def extract_convert_classes(name = nil)
    return ["Tasks::Db::Converts::Convert#{name.camelize}".constantize] if name.present?

    Tasks::Db::Converts::AbstractConvert.descendants.sort_by(&:name)
  end

  def clear_and_run(convert_clazz)
    m = convert_clazz.new
    m.truncate

    ActiveRecord::Base.transaction do
      m.convert
    end
  end
end
