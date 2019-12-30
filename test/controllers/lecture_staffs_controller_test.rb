# frozen_string_literal: true

require 'test_helper'

class LectureStaffsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @lecture_staff = lecture_staffs(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'STAFF_ADMIN')
  end

  test 'should get index' do
    get lecture_staffs_url
    assert_response :success
  end

  test 'should get new' do
    assert_raise(NameError) do
      get new_lecture_staff_url
    end
  end

  test 'should create lecture_staff' do
    assert_raise(ActionController::RoutingError) do
      post lecture_staffs_url, params: { lecture_staff: {} }
    end
  end

  test 'should show lecture_staff' do
    get lecture_staff_url(@lecture_staff)
    assert_response :success
  end

  test 'should get edit' do
    assert_raise(NoMethodError) do
      get edit_lecture_staff_url(@lecture_staff)
    end
  end

  test 'should update lecture_staff' do
    assert_raise(ActionController::RoutingError) do
      patch lecture_staff_url(@lecture_staff), params: { lecture_staff: {} }
    end
  end

  test 'should destroy lecture_staff' do
    assert_raise(ActionController::RoutingError) do
      delete lecture_staff_url(@lecture_staff)
    end
  end
end
