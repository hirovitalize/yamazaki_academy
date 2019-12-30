# frozen_string_literal: true

require 'test_helper'

class StudentPointsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @student_point = student_points(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'STUDENT_ADMIN')
  end

  test 'should get index' do
    get student_points_url
    assert_response :success
  end

  test 'should get new' do
    assert_raise(NameError) do
      get new_student_point_url
    end
  end

  test 'should create student_point' do
    assert_raise(ActionController::RoutingError) do
      post student_points_url, params: { student_point: {
        paid: @student_point.paid,
        reserved: @student_point.reserved,
        student_id: @student_point.student_id,
        total: @student_point.total,
        used: @student_point.used
      } }
    end
  end

  test 'should show student_point' do
    get student_point_url(@student_point)
    assert_response :success
  end

  test 'should get edit' do
    assert_raise(NoMethodError) do
      get edit_student_point_url(@student_point)
    end
  end

  test 'should update student_point' do
    assert_raise(ActionController::RoutingError) do
      patch student_point_url(@student_point), params: { student_point: {
        paid: @student_point.paid,
        reserved: @student_point.reserved,
        student_id: @student_point.student_id,
        total: @student_point.total,
        used: @student_point.used
      } }
    end
  end

  test 'should destroy student_point' do
    assert_raise(ActionController::RoutingError) do
      delete student_point_url(@student_point)
    end
  end
end
