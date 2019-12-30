# frozen_string_literal: true

require('./lib/tasks/task_util.rb')

namespace :lecture_mailer do
  task send_daily: :environment do
    TaskUtil.profile do
      LectureStaff.where(start_time: Time.zone.tomorrow.all_day).includes(:staff, :lecture).each do |lecture_staff|
        next if lecture_staff.lecture.canceled_status.present? || lecture_staff.staff.blank?

        LectureMailer.with(lecture_staff: lecture_staff).lecture_notification_mail.deliver_now
      end
    end
  end
end
