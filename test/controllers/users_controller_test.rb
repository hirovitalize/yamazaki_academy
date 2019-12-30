# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'STAFF_ADMIN')
  end

  test 'should get index' do
    get users_url
    assert_response :success
  end

  test 'should get new' do
    assert_raise(NameError) do
      get new_user_url
    end
  end

  test 'should create user' do
    assert_raise(ActionController::RoutingError) do
      post users_url, params: { user: {
        auth_token: @user.auth_token,
        current_sign_in_at: @user.current_sign_in_at,
        current_sign_in_ip: @user.current_sign_in_ip,
        email: @user.email + '.jp',
        encrypted_password: @user.encrypted_password,
        failed_attempts: @user.failed_attempts,
        last_sign_in_at: @user.last_sign_in_at,
        last_sign_in_ip: @user.last_sign_in_ip,
        locked_at: @user.locked_at,
        remember_created_at: @user.remember_created_at,
        reset_password_sent_at: @user.reset_password_sent_at,
        reset_password_token: @user.reset_password_token,
        sign_in_count: @user.sign_in_count,
        unlock_token: @user.unlock_token
      } }
    end
  end

  test 'should show user' do
    get user_url(@user)
    assert_response :success
  end

  test 'should get edit' do
    assert_raise(NoMethodError) do
      get edit_user_url(@user)
    end
  end

  test 'should update user' do
    assert_raise(ActionController::RoutingError) do
      patch users_url, params: { user: {
        auth_token: @user.auth_token,
        current_sign_in_at: @user.current_sign_in_at,
        current_sign_in_ip: @user.current_sign_in_ip,
        email: @user.email,
        encrypted_password: @user.encrypted_password,
        failed_attempts: @user.failed_attempts,
        last_sign_in_at: @user.last_sign_in_at,
        last_sign_in_ip: @user.last_sign_in_ip,
        locked_at: @user.locked_at,
        remember_created_at: @user.remember_created_at,
        reset_password_sent_at: @user.reset_password_sent_at,
        reset_password_token: @user.reset_password_token,
        sign_in_count: @user.sign_in_count,
        unlock_token: @user.unlock_token
      } }
    end
  end

  test 'should destroy user' do
    assert_raise(ActionController::RoutingError) do
      delete user_url(@user)
    end
  end
end
