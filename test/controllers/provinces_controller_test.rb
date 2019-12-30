# frozen_string_literal: true

require 'test_helper'

class ProvincesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @province = provinces(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'MASTER_CONTROL')
  end

  test 'should get index' do
    get provinces_url
    assert_response :success
  end

  test 'should get new' do
    get new_province_url
    assert_response :success
  end

  test 'should create province' do
    assert_difference('Province.count') do
      post provinces_url, params: { province: {
        code: @province.code,
        description: @province.description,
        name: @province.name

      } }

      assert_equal({}, assigns[:province].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'provinces', action: 'show', id: Province.last
  end

  test 'should show province' do
    get province_url(@province)
    assert_response :success
  end

  test 'should get edit' do
    get edit_province_url(@province)
    assert_response :success
  end

  test 'should update province' do
    patch province_url(@province), params: { province: {
      code: @province.code,
      description: @province.description,
      name: @province.name

    } }

    assert_equal({}, assigns[:province].errors.messages.select { |_, v| v.present? })
    assert_redirected_to controller: 'provinces', action: 'show', id: @province
  end

  test 'should destroy province' do
    Room.all.map(&:really_destroy!)
    Building.all.map(&:really_destroy!)
    @province.areas.map(&:really_destroy!)
    assert_difference('Province.without_deleted.count', -1) do
      delete province_url(@province)
      assert_equal({}, assigns[:province].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'provinces', action: :show
  end
end
