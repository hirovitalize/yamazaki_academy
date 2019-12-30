# frozen_string_literal: true

class StudentCommission < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail

  belongs_to :student
  belongs_to :cache_back_type, optional: true
  belongs_to :inflow_source, optional: true

  validates :referral, length: { in: (0..100) }, allow_blank: true
  validates :price, numericality: { only_integer: true,
                                    greater_than_or_equal_to: 0 }
  validates :commission_type, presence: true

  validates :cache_back_type_id, absence: true, if: -> { referral.present? || inflow_source_id.present? }
  validates :inflow_source_id, absence: true, if: -> { referral.present? || cache_back_type_id.present? }
  validates :referral, absence: true, if: -> { cache_back_type_id.present? || inflow_source_id.present? }

  enum commission_type: ::HashUtil.from_keys(%w[cache_back referral_person referral_inflow]), _prefix: true

  after_initialize :default_values, if: :new_record?

  def name
    return cache_back_type.name if commission_type_cache_back?
    return referral if commission_type_referral_person?

    inflow_source.name if commission_type_referral_inflow?
  end

  def commission_type
    return :cache_back if cache_back_type_id.present?
    return :referral_person if referral.present?

    :referral_inflow if inflow_source_id.present?
  end

  def commission_type=(value)
    # do nothing
  end

  commission_types.keys.each do |key|
    define_method("commission_type_#{key}?") do
      key.to_sym == commission_type
    end
  end

  private

  def default_values
    self.price = 0 if price.nil?
  end
end
