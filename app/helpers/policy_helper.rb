# frozen_string_literal: true

module PolicyHelper
  def policy?(model, action)
    command = "#{action}?"
    return true unless policy(model).respond_to?(command)

    policy(model).send(command)
  rescue Pundit::NotDefinedError
    true
  end
end
