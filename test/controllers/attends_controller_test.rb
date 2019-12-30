# frozen_string_literal: true

require 'test_helper'

class AttendsControllerControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @lecture = lectures(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'STUDENT_ADMIN')
    sign_in users(:one)
  end

  test 'should show attend' do
    get attends_url(id: @lecture.id)
    assert_response :success
  end

  test 'should check attend' do
    get attends_url(id: @lecture.id)
    assert_equal @lecture.confirmed, assigns[:lecture][:confirmed] # notyet
    get assigns[:url]
    @lecture.reload
    assert_equal @lecture.confirmed, 'approved'
    assert_not_nil(@lecture.lecture_attend_logs)
  end

  test 'should checked attend' do
    get attends_url(id: @lecture.id)
    get assigns[:url]
    assert_redirected_to controller: 'attends', action: :checked
  end
end
