# frozen_string_literal: true

require 'test_helper'

class SubjectsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @subject = subjects(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'MASTER_CONTROL')
  end

  test 'should get index' do
    get subjects_url
    assert_response :success
  end

  test 'should get new' do
    get new_subject_url
    assert_response :success
  end

  test 'should create subject' do
    assert_difference('Subject.count') do
      post subjects_url, params: { subject: {
        description: @subject.description,
        name: @subject.name,
        code: @subject.code,
        subject_category_id: @subject.subject_category_id,
        subject_type_id: @subject.subject_type_id
      } }

      assert_equal({}, assigns[:subject].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'subjects', action: 'show', id: Subject.last
  end

  test 'should show subject' do
    get subject_url(@subject)
    assert_response :success
  end

  test 'should get edit' do
    get edit_subject_url(@subject)
    assert_response :success
  end

  test 'should update subject' do
    patch subject_url(@subject), params: { subject: {
      description: @subject.description,
      name: @subject.name,
      subject_category_id: @subject.subject_category_id,
      subject_type_id: @subject.subject_type_id
    } }

    assert_equal({}, assigns[:subject].errors.messages.select { |_, v| v.present? })
    assert_redirected_to controller: 'subjects', action: 'show', id: @subject
  end

  test 'should destroy subject' do
    @subject.lectures.map(&:really_destroy!)
    @subject.klass_subjects.map(&:really_destroy!)
    @subject.klass_template_subjects.map(&:really_destroy!)
    assert_difference('Subject.without_deleted.count', -1) do
      delete subject_url(@subject)
    end

    assert_redirected_to controller: 'subjects', action: :show
  end
end
