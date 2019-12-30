# frozen_string_literal: true

class SharedKlassKlassSubject < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  belongs_to :klass_subject
  belongs_to :klass
end
