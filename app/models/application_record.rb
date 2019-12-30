# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def to_label
    [
      respond_to?(:deleted?) && deleted? ? '[削除]' : nil,
      respond_to?(:code?) && code.present? ? "(#{code})" : nil,
      respond_to?(:name) ? name : id
    ].compact.join(' ')
  end
end
