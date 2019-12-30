# frozen_string_literal: true

require 'test_helper'

class StudentMentorsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @student_mentor = student_mentors(:one)
    sign_in users(:one)
  end

  test 'should get index' do
    get student_mentors_url
    assert_response :success
  end

  test 'should get new' do
    get new_student_mentor_url
    assert_response :success
  end

  test 'should create student_mentor' do
    assert_difference('StudentMentor.count') do
      post student_mentors_url, params: { student_mentor: {
        staff_id: @student_mentor.staff_id,
        student_id: 2,
        staff_type: @student_mentor.staff_type

      } }

      assert_equal({}, assigns[:student_mentor].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'student_mentors', action: 'show', id: StudentMentor.last
  end

  test 'should show student_mentor' do
    get student_mentor_url(@student_mentor)
    assert_response :success
  end

  test 'should get edit' do
    get edit_student_mentor_url(@student_mentor)
    assert_response :success
  end

  test 'should update student_mentor' do
    patch student_mentor_url(@student_mentor), params: { student_mentor: {
      staff_id: @student_mentor.staff_id,
      student_id: @student_mentor.student_id,
      staff_type: @student_mentor.staff_type

    } }

    assert_equal({}, assigns[:student_mentor].errors.messages.select { |_, v| v.present? })
    assert_redirected_to controller: 'student_mentors', action: 'show', id: @student_mentor
  end

  test 'should destroy student_mentor' do
    assert_difference('StudentMentor.without_deleted.count', -1) do
      delete student_mentor_url(@student_mentor)
      assert_equal({}, assigns[:student_mentor].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'student_mentors', action: :show
  end
end
