# frozen_string_literal: true

class RoutingUtil
  include ActionDispatch::Routing::PolymorphicRoutes
  include Rails.application.routes.url_helpers
  include Singleton

  def link(object, action = nil)
    polymorphic_path(object, action: action)
  rescue NoMethodError
    # routingが定義されていない
    nil
  end
end
