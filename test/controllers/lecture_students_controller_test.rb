# frozen_string_literal: true

require 'test_helper'

class LectureStudentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @lecture_student = lecture_students(:one)
    sign_in users(:one)
  end

  test 'should get index' do
    get lecture_students_url
    assert_response :success
  end

  test 'should show lecture_student' do
    get lecture_student_url(@lecture_student)
    assert_response :success
  end
end
