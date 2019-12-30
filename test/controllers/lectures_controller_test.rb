# frozen_string_literal: true

require 'test_helper'

class LecturesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @lecture = lectures(:one)
    sign_in users(:one)
  end

  test 'should get klass_calendar' do
    sign_out users(:one)
    get klass_calendar_lectures_url
    assert_redirected_to users_sign_in_url
  end

  test 'should get staff_calendar' do
    sign_out users(:one)
    get staff_calendar_lectures_url
    assert_redirected_to users_sign_in_url
  end

  test 'should get index' do
    users(:one).staff.roles.create!(name: 'aaa', code: 'STUDENT_ADMIN')
    get lectures_url
    assert_response :success
  end

  test 'should get new' do
    get new_lecture_url
    assert_response :success
  end

  test 'should create lecture' do
    assert_difference('Lecture.count') do
      post lectures_url, params: { lecture: {
        confirmed: @lecture.confirmed,
        confirmer_id: @lecture.confirmer_id,
        description: @lecture.description,
        finish_time: @lecture.finish_time,
        name: @lecture.name,
        start_time: @lecture.start_time,
        subject_id: @lecture.subject_id,
        klass_subject_id: @lecture.klass_subject_id
      } }

      assert_equal({}, assigns[:lecture].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'lectures', action: 'show', id: Lecture.last
  end

  test 'should show lecture' do
    get lecture_url(@lecture)
    assert_response :success
  end

  test 'should get edit' do
    users(:one).staff.roles.create!(name: 'aaa', code: 'STUDENT_ADMIN')
    get edit_lecture_url(@lecture)
    assert_response :success
  end

  test 'should update lecture' do
    users(:one).staff.roles.create!(name: 'aaa', code: 'STUDENT_ADMIN')
    patch lecture_url(@lecture), params: { lecture: {
      confirmed: @lecture.confirmed,
      confirmer_id: @lecture.confirmer_id,
      description: @lecture.description,
      finish_time: @lecture.finish_time,
      name: @lecture.name,
      start_time: @lecture.start_time,
      subject_id: @lecture.subject_id,
      klass_subject_id: @lecture.klass_subject_id
    } }

    assert_equal({}, assigns[:lecture].errors.messages.select { |_, v| v.present? })
    assert_redirected_to controller: 'lectures', action: 'show', id: @lecture
  end

  test 'should get confirm_klass_subject' do
    get confirm_klass_subject_lectures_path(lecture_ids: @lecture.id)
    assert_response :success
  end

  test 'should duplicate_klass_subject lecture' do
    post duplicate_klass_subject_lectures_path(lecture_ids: @lecture.id, remain_lectures: 14)
    @lecture.reload

    # 授業が1つあり、残りの授業数が14のため「15」になる
    assert_equal 15, @lecture.klass_subject.lectures.count

    # "2019/03/01" から14週間後は "2019/06/07"
    assert_equal '2020/06/07', @lecture.klass_subject.lectures.last.start_time.to_s(:date)

    assert_redirected_to controller: 'klass_subjects', action: 'show', id: @lecture.klass_subject_id
  end

  test 'should change_request_for_vip lecture' do
    assert_not_equal '時間変更中', @lecture.tag_list.first

    post change_request_for_vip_lecture_url(@lecture)

    @lecture.reload
    assert_equal '時間変更中', @lecture.tag_list.first
  end

  test 'should approve lecture' do
    assert_raise(Pundit::NotAuthorizedError) do
      # users(:one).staff.roles.create!(name: 'aaa', code: 'STUDENT_ADMIN')
      post approve_lecture_url(@lecture)
    end
  end

  test 'should unapprove lecture' do
    assert_raise(Pundit::NotAuthorizedError) do
      # users(:one).staff.roles.create!(name: 'aaa', code: 'STUDENT_ADMIN')
      post unapprove_lecture_url(@lecture)
    end
  end

  test 'should back_confirmed lecture' do
    assert_raise(Pundit::NotAuthorizedError) do
      # users(:one).staff.roles.create!(name: 'aaa', code: 'STUDENT_ADMIN')
      post back_confirmed_lecture_url(@lecture)
    end
  end

  test 'should destroy lecture' do
    users(:one).staff.roles.create!(name: 'aaa', code: 'STUDENT_ADMIN')
    @lecture.lecture_students.map(&:really_destroy!)
    @lecture.lecture_staffs.map(&:really_destroy!)
    assert_difference('Lecture.without_deleted.count', -1) do
      delete lecture_url(@lecture)
    end

    assert_redirected_to controller: 'lectures', action: :show
  end
end
