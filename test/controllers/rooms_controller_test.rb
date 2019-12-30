# frozen_string_literal: true

require 'test_helper'

class RoomsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @room = rooms(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'MASTER_CONTROL')
  end

  test 'should get index' do
    get rooms_url
    assert_response :success
  end

  test 'should get new' do
    get new_room_url
    assert_response :success
  end

  test 'should create room' do
    assert_difference('Room.count') do
      post rooms_url, params: { room: {
        description: @room.description,
        name: @room.name,
        wday_0_close_time: @room.wday_0_close_time,
        wday_0_open_time: @room.wday_0_open_time,
        wday_1_close_time: @room.wday_1_close_time,
        wday_1_open_time: @room.wday_1_open_time,
        wday_2_close_time: @room.wday_2_close_time,
        wday_2_open_time: @room.wday_2_open_time,
        wday_3_close_time: @room.wday_3_close_time,
        wday_3_open_time: @room.wday_3_open_time,
        wday_4_close_time: @room.wday_4_close_time,
        wday_4_open_time: @room.wday_4_open_time,
        wday_5_close_time: @room.wday_5_close_time,
        wday_5_open_time: @room.wday_5_open_time,
        wday_6_close_time: @room.wday_6_close_time,
        wday_6_open_time: @room.wday_6_open_time,
        seat_number: @room.seat_number

      } }

      assert_equal({}, assigns[:room].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'rooms', action: 'show', id: Room.last
  end

  test 'should show room' do
    get room_url(@room)
    assert_response :success
  end

  test 'should get edit' do
    get edit_room_url(@room)
    assert_response :success
  end

  test 'should update room' do
    patch room_url(@room), params: { room: {
      description: @room.description,
      name: @room.name,
      wday_0_close_time: @room.wday_0_close_time,
      wday_0_open_time: @room.wday_0_open_time,
      wday_1_close_time: @room.wday_1_close_time,
      wday_1_open_time: @room.wday_1_open_time,
      wday_2_close_time: @room.wday_2_close_time,
      wday_2_open_time: @room.wday_2_open_time,
      wday_3_close_time: @room.wday_3_close_time,
      wday_3_open_time: @room.wday_3_open_time,
      wday_4_close_time: @room.wday_4_close_time,
      wday_4_open_time: @room.wday_4_open_time,
      wday_5_close_time: @room.wday_5_close_time,
      wday_5_open_time: @room.wday_5_open_time,
      wday_6_close_time: @room.wday_6_close_time,
      wday_6_open_time: @room.wday_6_open_time,
      seat_number: @room.seat_number

    } }

    assert_equal({}, assigns[:room].errors.messages.select { |_, v| v.present? })
    assert_redirected_to controller: 'rooms', action: 'show', id: @room
  end

  test 'should destroy room' do
    @room.room_room_groups.map(&:really_destroy!)
    @room.room_equipments.map(&:really_destroy!)
    assert_difference('Room.without_deleted.count', -1) do
      delete room_url(@room)
    end

    assert_redirected_to controller: 'rooms', action: :show
  end
end
