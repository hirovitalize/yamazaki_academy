# frozen_string_literal: true

class KlassTemplateSubject < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  belongs_to :klass_template
  belongs_to :subject
end
