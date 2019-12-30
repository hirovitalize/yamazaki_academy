# frozen_string_literal: true

require 'test_helper'

class SubjectTypesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @subject_type = subject_types(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'MASTER_CONTROL')
  end

  test 'should get index' do
    get subject_types_url
    assert_response :success
  end

  test 'should get new' do
    get new_subject_type_url
    assert_response :success
  end

  test 'should create subject_type' do
    assert_difference('SubjectType.count') do
      post subject_types_url, params: { subject_type: {
        color: @subject_type.color,
        description: @subject_type.description,
        name: @subject_type.name
      } }

      assert_equal({}, assigns[:subject_type].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'subject_types', action: 'show', id: SubjectType.last
  end

  test 'should show subject_type' do
    get subject_type_url(@subject_type)
    assert_response :success
  end

  test 'should get edit' do
    get edit_subject_type_url(@subject_type)
    assert_response :success
  end

  test 'should update subject_type' do
    patch subject_type_url(@subject_type), params: { subject_type: {
      color: @subject_type.color,
      description: @subject_type.description,
      name: @subject_type.name
    } }

    assert_equal({}, assigns[:subject_type].errors.messages.select { |_, v| v.present? })
    assert_redirected_to controller: 'subject_types', action: 'show', id: @subject_type
  end

  test 'should destroy subject_type' do
    @subject_type.subject_type_room_groups.map(&:really_destroy!)
    @subject_type.subjects.map(&:really_destroy!)
    assert_difference('SubjectType.without_deleted.count', -1) do
      delete subject_type_url(@subject_type)
    end

    assert_redirected_to controller: 'subject_types', action: :show
  end
end
