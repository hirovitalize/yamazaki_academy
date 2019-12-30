# frozen_string_literal: true

require 'test_helper'

class RolesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @role = roles(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'ROLE_CONTROL')
  end

  test 'should get index' do
    get roles_url
    assert_response :success
  end

  test 'should get new' do
    assert_raise(NameError) do
      get new_role_url
    end
  end

  test 'should create role' do
    assert_raise(ActionController::RoutingError) do
      post roles_url, params: { role: {} }
    end
  end

  test 'should show role' do
    get role_url(@role)
    assert_response :success
  end

  test 'should get edit' do
    get edit_role_url(@role)
    assert_response :success
  end

  test 'should update role' do
    patch role_url(@role), params: { role: {
      code: @role.code,
      description: @role.description,
      name: @role.name
    } }

    assert_equal({}, assigns[:role].errors.messages.select { |_, v| v.present? })
    assert_redirected_to controller: 'roles', action: 'show', id: @role
  end

  test 'should destroy role' do
    assert_raise(ActionController::RoutingError) do
      delete role_url(@role)
    end
  end
end
