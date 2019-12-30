# frozen_string_literal: true

require 'test_helper'

class StaffsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @staff = staffs(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'STAFF_ADMIN')
  end

  test 'should get index' do
    get staffs_url
    assert_response :success
  end

  test 'should get new' do
    get new_staff_url
    assert_response :success
  end

  test 'should create staff' do
    assert_difference('Staff.count') do
      post staffs_url, params: { staff: {
        birthday: @staff.birthday,
        name: @staff.name,
        code: @staff.code,
        tel: @staff.tel,
        user_id: @staff.user_id
      } }

      assert_equal({}, assigns[:staff].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'staffs', action: 'show', id: Staff.last
  end

  test 'should show staff' do
    get staff_url(@staff)
    assert_response :success
  end

  test 'should get edit' do
    get edit_staff_url(@staff)
    assert_response :success
  end

  test 'should update staff' do
    patch staff_url(@staff), params: { staff: {
      birthday: @staff.birthday,
      name: @staff.name,
      code: @staff.code,
      tel: @staff.tel,
      user_id: @staff.user_id
    } }

    assert_equal({}, assigns[:staff].errors.messages.select { |_, v| v.present? })
    assert_redirected_to controller: 'staffs', action: 'show', id: @staff
  end

  test 'should destroy staff' do
    @staff.student_mentors.map(&:really_destroy!)
    @staff.lecture_staffs.map(&:really_destroy!)
    @staff.staff_roles.map(&:really_destroy!)
    assert_difference('Staff.without_deleted.count', -1) do
      delete staff_url(@staff)
    end

    assert_redirected_to controller: 'staffs', action: :show
  end
end
