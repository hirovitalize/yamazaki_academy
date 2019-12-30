# frozen_string_literal: true

require 'test_helper'

class StudentMycoachesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @student_mycoach = student_mycoaches(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'STUDENT_ADMIN')
  end

  test 'should get index' do
    get student_mycoaches_url
    assert_response :success
  end

  test 'should get new' do
    assert_raise(NameError) do
      get new_student_mycoach_url
    end
  end

  test 'should create student_mycoach' do
    assert_raise(ActionController::RoutingError) do
      post student_mycoaches_url, params: { student_mycoach: {
        auth_token: @student_mycoach.auth_token,
        current_sign_in_at: @student_mycoach.current_sign_in_at,
        current_sign_in_ip: @student_mycoach.current_sign_in_ip,
        email: @student_mycoach.email,
        encrypted_password: @student_mycoach.encrypted_password,
        last_sign_in_at: @student_mycoach.last_sign_in_at,
        last_sign_in_ip: @student_mycoach.last_sign_in_ip,
        remember_created_at: @student_mycoach.remember_created_at,
        sign_in_count: @student_mycoach.sign_in_count
      } }
    end
  end

  test 'should show student_mycoach' do
    get student_mycoach_url(@student_mycoach)
    assert_response :success
  end

  test 'should get edit' do
    assert_raise(NoMethodError) do
      get edit_student_mycoach_url(@student_mycoach)
    end
  end

  test 'should update student_mycoach' do
    assert_raise(ActionController::RoutingError) do
      patch student_mycoach_url(@student_mycoach), params: { student_mycoach: {
        auth_token: @student_mycoach.auth_token,
        current_sign_in_at: @student_mycoach.current_sign_in_at,
        current_sign_in_ip: @student_mycoach.current_sign_in_ip,
        email: @student_mycoach.email,
        encrypted_password: @student_mycoach.encrypted_password,
        last_sign_in_at: @student_mycoach.last_sign_in_at,
        last_sign_in_ip: @student_mycoach.last_sign_in_ip,
        remember_created_at: @student_mycoach.remember_created_at,
        sign_in_count: @student_mycoach.sign_in_count
      } }
    end
  end

  test 'should destroy student_mycoach' do
    assert_raise(ActionController::RoutingError) do
      delete student_mycoach_url(@student_mycoach)
    end
  end
end
