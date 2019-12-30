# frozen_string_literal: true

require 'test_helper'

class AreasControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @area = areas(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'MASTER_CONTROL')
  end

  test 'should get index' do
    get areas_url
    assert_response :success
  end

  test 'should get new' do
    get new_area_url
    assert_response :success
  end

  test 'should create area' do
    assert_difference('Area.count') do
      post areas_url, params: { area: {
        description: @area.description,
        name: @area.name,
        province_id: @area.province_id,
        code: @area.code
      } }

      assert_equal({}, assigns[:area].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'areas', action: 'show', id: Area.last
  end

  test 'should show area' do
    get area_url(@area)
    assert_response :success
  end

  test 'should get edit' do
    get edit_area_url(@area)
    assert_response :success
  end

  test 'should update area' do
    patch area_url(@area), params: { area: {
      code: @area.code,
      description: @area.description,
      name: @area.name
    } }

    assert_equal({}, assigns[:area].errors.messages.select { |_, v| v.present? })
    assert_redirected_to controller: 'areas', action: 'show', id: @area
  end

  test 'should destroy area' do
    @area.klasses.map(&:really_destroy!)
    Room.all.map(&:really_destroy!)
    @area.buildings.map(&:really_destroy!)
    Student.all.map(&:really_destroy!)
    assert_difference('Area.without_deleted.count', -1) do
      delete area_url(@area)
      assert_equal({}, assigns[:area].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'areas', action: :show
  end
end
