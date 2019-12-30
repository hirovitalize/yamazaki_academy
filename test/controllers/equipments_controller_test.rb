# frozen_string_literal: true

require 'test_helper'

class EquipmentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @equipment = equipments(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'MASTER_CONTROL')
  end

  test 'should get index' do
    get equipments_url
    assert_response :success
  end

  test 'should get new' do
    get new_equipment_url
    assert_response :success
  end

  test 'should create equipment' do
    assert_difference('Equipment.count') do
      post equipments_url, params: { equipment: {
        description: @equipment.description,
        name: @equipment.name

      } }

      assert_equal({}, assigns[:equipment].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'equipments', action: 'show', id: Equipment.last
  end

  test 'should show equipment' do
    get equipment_url(@equipment)
    assert_response :success
  end

  test 'should get edit' do
    get edit_equipment_url(@equipment)
    assert_response :success
  end

  test 'should update equipment' do
    patch equipment_url(@equipment), params: { equipment: {
      description: @equipment.description,
      name: @equipment.name

    } }

    assert_equal({}, assigns[:equipment].errors.messages.select { |_, v| v.present? })
    assert_redirected_to controller: 'equipments', action: 'show', id: @equipment
  end

  test 'should destroy equipment' do
    assert_difference('Equipment.without_deleted.count', -1) do
      delete equipment_url(@equipment)
    end

    assert_redirected_to controller: 'equipments', action: :show
  end
end
