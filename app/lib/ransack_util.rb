# frozen_string_literal: true

module RansackUtil
  PER_PAGE_LIST = [['20', 20], ['50', 50], ['100', 100], ['500', 500]].freeze
  PER_DEFAULT = 50
  PAGE_DEFAULT = 1

  def self.paged_scope(ransack, params)
    ransack.result(distinct: true)
           .page(params[:page] || PAGE_DEFAULT)
           .per(params[:per] || PER_DEFAULT)
  end

  def self.append_paranoided(params)
    return if params.dig(:q, :with_deleted) || params.dig(:q, :only_deleted)

    params[:q] = {} if params.dig(:q).nil?
    params[:q][:without_deleted] = true
  end
end
