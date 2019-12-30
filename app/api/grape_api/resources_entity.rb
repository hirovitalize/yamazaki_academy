# frozen_string_literal: true

module GrapeApi
  class ResourcesEntity < Grape::Entity
    expose :id, documentation: { type: Integer, desc: 'ID' }
    expose :created_at, documentation: { type: DateTime, desc: 'created_at' }
  end
end
