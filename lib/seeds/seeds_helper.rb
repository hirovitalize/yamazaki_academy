# frozen_string_literal: true

module Seeds
  module SeedsHelper
    def self.truncate(clazz)
      raise "#{clazz.class} is not Supported." unless clazz.ancestors.include? ActiveRecord::Base

      clazz.connection.execute("truncate table #{clazz.table_name}")
    end

    def self.import(instances, raising: true, validate: true)
      return if instances.empty?

      clazz = instances.first.class

      return (clazz.import instances, validate: validate) unless raising

      return (clazz.import! instances) if validate

      result = clazz.import(instances, validate: validate)
      raise "#{clazz.name}で死んだよ！ 詳しくは import(validate: true)で見てね！" unless result
    end
  end
end
