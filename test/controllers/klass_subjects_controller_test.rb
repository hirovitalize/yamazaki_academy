# frozen_string_literal: true

require 'test_helper'

class KlassSubjectsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @klass_subject = klass_subjects(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'MASTER_CONTROL')
  end

  test 'should get index' do
    get klass_subjects_url
    assert_response :success
  end

  test 'should get new' do
    get new_klass_subject_url
    assert_response :success
  end

  test 'should create klass_subject' do
    assert_difference('KlassSubject.count') do
      post klass_subjects_url, params: { klass_subject: {
        code: @klass_subject.code,
        description: @klass_subject.description,
        klass_id: @klass_subject.klass_id,
        subject_id: @klass_subject.subject_id,
        staff_id: @klass_subject.staff_id,
        lecture_num: @klass_subject.lecture_num,
        interval: @klass_subject.interval,
        start_time: @klass_subject.start_time,
        fixed: @klass_subject.fixed
      } }

      assert_equal({}, assigns[:klass_subject].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'klass_subjects', action: 'show', id: KlassSubject.last
  end

  test 'should show klass_subject' do
    get klass_subject_url(@klass_subject)
    assert_response :success
  end

  test 'should get edit' do
    get edit_klass_subject_url(@klass_subject)
    assert_response :success
  end

  test 'should update klass_subject' do
    patch klass_subject_url(@klass_subject), params: { klass_subject: {
      klass_id: @klass_subject.klass_id,
      subject_id: @klass_subject.subject_id,
      staff_id: @klass_subject.staff_id,
      description: @klass_subject.description,
      lecture_num: @klass_subject.lecture_num,
      interval: @klass_subject.interval,
      start_time: @klass_subject.start_time,
      fixed: @klass_subject.fixed
    } }

    assert_equal({}, assigns[:klass_subject].errors.messages.select { |_, v| v.present? })
    assert_redirected_to controller: 'klass_subjects', action: 'show', id: @klass_subject
  end

  test 'should fixed klass_subject' do
    # カリキュラムを確定する
    patch klass_subject_url(@klass_subject), params: { klass_subject: {
      klass_id: @klass_subject.klass_id,
      subject_id: @klass_subject.subject_id,
      staff_id: @klass_subject.staff_id,
      description: @klass_subject.description,
      lecture_num: @klass_subject.lecture_num,
      interval: @klass_subject.interval,
      start_time: @klass_subject.start_time,
      fixed: 'true'
    } }

    # 確定したカリキュラムの授業を更新するとエラーが発生する
    @lecture = lectures(:one)
    assert_raise(Pundit::NotAuthorizedError) do
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
    end
  end

  test 'should delete_lectures klass_subject' do
    assert_difference('Lecture.without_deleted.count', -1) do
      post delete_lectures_klass_subjects_path(id: @klass_subject.id)
    end

    assert_redirected_to controller: 'klass_subjects', action: :show, id: @klass_subject
  end

  test 'should destroy klass_subject' do
    @klass_subject.lectures.map(&:really_destroy!)
    assert_difference('KlassSubject.without_deleted.count', -1) do
      delete klass_subject_url(@klass_subject)
    end

    assert_redirected_to controller: 'klass_subjects', action: :show
  end
end
