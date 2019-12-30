# frozen_string_literal: true

require 'test_helper'

class CoursesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @course = courses(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'MASTER_CONTROL')
  end

  test 'should get index' do
    get courses_url
    assert_response :success
  end

  test 'should get new' do
    get new_course_url
    assert_response :success
  end

  test 'should create course' do
    assert_difference('Course.count') do
      post courses_url, params: { course: {
        course_category_id: @course.course_category_id,
        description: @course.description,
        name: @course.name,
        price: @course.price
      } }

      assert_equal({}, assigns[:course].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'courses', action: 'show', id: Course.last
  end

  test 'should show course' do
    get course_url(@course)
    assert_response :success
  end

  test 'should get edit' do
    get edit_course_url(@course)
    assert_response :success
  end

  test 'should update course' do
    patch course_url(@course), params: { course: {
      course_category_id: @course.course_category_id,
      description: @course.description,
      name: @course.name,
      price: @course.price

    } }

    assert_equal({}, assigns[:course].errors.messages.select { |_, v| v.present? })
    assert_redirected_to controller: 'courses', action: 'show', id: @course
  end

  test 'should destroy course' do
    assert_difference('Course.without_deleted.count', -1) do
      delete course_url(@course)
    end

    assert_redirected_to controller: 'courses', action: :show
  end
end
