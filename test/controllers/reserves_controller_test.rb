# frozen_string_literal: true

require 'test_helper'

class ReservesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @reserve = reserves(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'ROOM_RESERVABLE')
  end

  test 'should get index_calendar' do
    get index_calendar_reserves_url
    assert_response :success
  end

  test 'should get calendar' do
    get calendar_reserves_url
    assert_response :success
  end

  test 'should get index' do
    get reserves_url
    assert_response :success
  end

  test 'should get new' do
    get new_reserve_url
    assert_response :success
  end

  test 'should create reserve' do
    assert_difference('Reserve.count') do
      post reserves_url, params: { reserve: {
        start_time: (Time.zone.now + 3.days).beginning_of_day + 13.hours,
        finish_time: (Time.zone.now + 3.days).beginning_of_day + 15.hours,
        lecture_id: @reserve.lecture_id,
        room_id: @reserve.room_id
      } }

      assert_equal({}, assigns[:reserve].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'reserves', action: 'show', id: Reserve.last
  end

  test 'should show reserve' do
    get reserve_url(@reserve)
    assert_response :success
  end

  test 'should get edit' do
    get edit_reserve_url(@reserve)
    assert_response :success
  end

  test 'should update reserve' do
    patch reserve_url(@reserve), params: { reserve: {
      finish_time: @reserve.finish_time,
      lecture_id: @reserve.lecture_id,
      room_id: @reserve.room_id,
      start_time: @reserve.start_time
    } }

    assert_equal({}, assigns[:reserve].errors.messages.select { |_, v| v.present? })
    assert_redirected_to controller: 'reserves', action: 'show', id: @reserve
  end

  test 'should destroy reserve' do
    assert_difference('Reserve.without_deleted.count', -1) do
      delete reserve_url(@reserve)
    end

    assert_redirected_to controller: 'reserves', action: :show
  end
end
