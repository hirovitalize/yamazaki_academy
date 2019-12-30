# frozen_string_literal: true

require 'test_helper'

class LectureAttendLogsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @lecture_attend_log = lecture_attend_logs(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'STUDENT_ADMIN')
  end

  test 'should get index' do
    get lecture_attend_logs_url
    assert_response :success
  end

  test 'should show lecture_attend_log' do
    get lecture_attend_log_url(@lecture_attend_log)
    assert_response :success
  end
end
