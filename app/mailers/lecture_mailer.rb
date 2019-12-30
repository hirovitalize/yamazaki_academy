# frozen_string_literal: true

class LectureMailer < ApplicationMailer
  default from: Settings.mail.address.default_from

  def lecture_notification_mail
    @lecture_staff = params[:lecture_staff]
    @url = 'http://rooms.coach-ac.info'
    @staff = @lecture_staff.staff
    mail(
      to: @staff.email,
      subject: '行知学園教室予約システムです。'
    )
  end
end
