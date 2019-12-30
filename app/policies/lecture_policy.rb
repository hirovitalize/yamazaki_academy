# frozen_string_literal: true

class LecturePolicy < ApplicationPolicy
  def index?
    return true if user.role? 'STUDENT_ADMIN'
    return true if user.role? 'STAFF_ADMIN'
    return true if user.role? 'ROOM_RESERVABLE'
    return true if user.role? 'PAYMENT'
    return true if user.role? 'PAYMENT_ADMIN'

    false
  end

  def create?
    return true if user.role? 'STUDENT_ADMIN'

    if record.subject&.personal
      return false unless record.vip_lecture_creatable_time?
    end

    true
  end

  def change_request_for_vip?
    return false unless record.subject&.personal
    return false if record.reserve.present?
    return false unless record.updateable_time?
    return false if user.staff.id.in? record.staff_ids
    return false unless user.role? 'ROOM_RESERVABLE'

    true
  end

  def change_request_for_group?
    return false if record.subject&.personal
    return false unless record.updateable_time?
    return false if user.staff.id.in? record.staff_ids
    return false unless user.role?('STUDENT_ADMIN' || 'ROOM_RESERVABLE')

    true
  end

  def klass_calendar?
    user.role? 'STUDENT_ADMIN'
  end

  def staff_calendar?
    user.role? 'STUDENT_ADMIN'
  end

  def back_confirmed?
    return false unless record.may_back_confirmed?
    return false unless record.past?
    return false if user.staff.id.in? record.staff_ids

    user.role? 'STUDENT_ADMIN'
  end

  def approve?
    return false unless record.may_approve?
    return false unless record.past?
    return false if user.staff.id.in? record.staff_ids

    user.role? 'STUDENT_ADMIN'
  end

  def unapprove?
    return false unless record.may_unapprove?
    return false unless record.past?
    return false if user.staff.id.in? record.staff_ids

    user.role? 'STUDENT_ADMIN'
  end

  def cancel?
    return false unless record.canceled_status.nil?
    return false if record.confirmed_approved?

    if record.updateable_time?
      return true if user.id == record.creator_id
      return true if user.staff.id.in? record.staff_ids
      return true if user.role? 'STUDENT_ADMIN'
    end

    false
  end

  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/BlockNesting
  def update?
    if record.updateable_time?
      if record.subject&.personal?
        if record.vip_updateable_time?
          return true if user.staff.id.in? record.staff_ids
          return true if user.id == record.creator_id
        end
      end


      if record.klass_subject&.fixed == false
        return true if user.staff.id.in? record.staff_ids
        return true if user.id == record.creator_id
      end
      return true if user.role? 'STUDENT_ADMIN'
    end

    false
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/BlockNesting

  alias edit? update?
  alias destroy? update?
  alias duplicate? update?
end
