# frozen_string_literal: true

require 'test_helper'

class BuildingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @building = buildings(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'MASTER_CONTROL')
  end

  test 'should get index' do
    get buildings_url
    assert_response :success
  end

  test 'should get new' do
    get new_building_url
    assert_response :success
  end

  test 'should create building' do
    assert_difference('Building.count') do
      post buildings_url, params: { building: {
        address: @building.address,
        area_id: @building.area_id,
        description: @building.description,
        name: @building.name

      } }

      assert_equal({}, assigns[:building].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'buildings', action: 'show', id: Building.last
  end

  test 'should show building' do
    get building_url(@building)
    assert_response :success
  end

  test 'should get edit' do
    get edit_building_url(@building)
    assert_response :success
  end

  test 'should update building' do
    patch building_url(@building), params: { building: {
      address: @building.address,
      area_id: @building.area_id,
      description: @building.description,
      name: @building.name

    } }

    assert_equal({}, assigns[:building].errors.messages.select { |_, v| v.present? })
    assert_redirected_to controller: 'buildings', action: 'show', id: @building
  end

  test 'should destroy building' do
    @building.rooms.map(&:really_destroy!)
    assert_difference('Building.without_deleted.count', -1) do
      delete building_url(@building)
    end

    assert_redirected_to controller: 'buildings', action: :show
  end
end
