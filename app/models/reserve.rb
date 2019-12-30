# frozen_string_literal: true

class Reserve < ApplicationRecord
  include AASM
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail
  include OptimisticLockValidatable

  include HasDatetimeRange
  acts_as_datetimerange :start_time, :finish_time, as: :reserve, include_to: false

  belongs_to :room
  belongs_to :lecture, optional: true

  validates :comment, length: { in: (0..100) }, allow_blank: true
  validates :start_time, presence: true
  validates :finish_time, presence: true
  validates :start_time, timeliness: { after: :now }, on: :form, if: -> { start_time_changed? }

  validate :check_room_time_for_reserve
  validate :check_room_time_uniqueness

  after_initialize :default_values, if: :new_record?

  def started?
    start_time < Time.zone.now
  end

  def name
    [
      room&.name,
      "#{I18n.l(start_time, format: :short)} - #{I18n.l(finish_time, format: :short)}"
    ].compact.join(' : ')
  end

  def self.date_range_included(date)
    where('? <= start_time and start_time < ?', date.to_date, date.to_date + 1)
  end

  private

  def default_values; end

  def check_room_time_for_reserve
    return if room.blank?
    return if start_time.blank?
    return if finish_time.blank?
    return unless start_time > Time.zone.now

    check_room_time_for_reserve_internal "wday_#{start_time.wday}"
  end

  def check_room_time_for_reserve_internal(field)
    open_time = room.send("#{field}_open_time")
    errors.add(:start_time, "は部屋の予約可能時間(#{open_time.to_s(:time)}～)にしてください") if open_time.present? && start_time.to_s(:time) < open_time.to_s(:time)

    close_time = room.send("#{field}_close_time")
    errors.add(:finish_time, "は部屋の予約可能時間(～#{close_time.to_s(:time)})にしてください") if close_time.present? && finish_time.to_s(:time) > close_time.to_s(:time)
  end

  def check_room_time_uniqueness
    return if start_time.blank?
    return if finish_time.blank?

    overlaps = Reserve.where(room: room).reserve_range_overlaps(start_time, finish_time).where.not(start_time: finish_time).where.not(finish_time: start_time)
    overlaps = overlaps.where.not(id: id) unless new_record?
    errors.add(:start_time, "重複しています。#{overlaps.first.to_label}") if overlaps.exists?
  end
end
