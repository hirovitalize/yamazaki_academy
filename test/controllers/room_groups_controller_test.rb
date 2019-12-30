# frozen_string_literal: true

require 'test_helper'

class RoomGroupsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @room_group = room_groups(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'MASTER_CONTROL')
  end

  test 'should get index' do
    get room_groups_url
    assert_response :success
  end

  test 'should get new' do
    get new_room_group_url
    assert_response :success
  end

  test 'should create room_group' do
    assert_difference('RoomGroup.count') do
      post room_groups_url, params: { room_group: {
        description: @room_group.description,
        name: @room_group.name,
        rules: @room_group.rules
      } }

      assert_equal({}, assigns[:room_group].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'room_groups', action: 'show', id: RoomGroup.last
  end

  test 'should show room_group' do
    get room_group_url(@room_group)
    assert_response :success
  end

  test 'should get edit' do
    get edit_room_group_url(@room_group)
    assert_response :success
  end

  test 'should update room_group' do
    patch room_group_url(@room_group), params: { room_group: {
      description: @room_group.description,
      name: @room_group.name,
      rules: @room_group.rules
    } }

    assert_equal({}, assigns[:room_group].errors.messages.select { |_, v| v.present? })
    assert_redirected_to controller: 'room_groups', action: 'show', id: @room_group
  end

  test 'should destroy room_group' do
    @room_group.room_room_groups.map(&:really_destroy!)
    @room_group.subject_type_room_groups.map(&:really_destroy!)
    assert_difference('RoomGroup.without_deleted.count', -1) do
      delete room_group_url(@room_group)
    end

    assert_redirected_to controller: 'room_groups', action: :show
  end
end
