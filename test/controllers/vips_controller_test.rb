# frozen_string_literal: true

require 'test_helper'

class VipsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @vip = vips(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'MASTER_CONTROL')
  end

  test 'should get index' do
    get vips_url
    assert_response :success
  end

  test 'should get new' do
    get new_vip_url
    assert_response :success
  end

  test 'should create vip' do
    assert_difference('Vip.count') do
      post vips_url, params: { vip: {
        course_category_id: @vip.course_category_id,
        description: @vip.description,
        name: @vip.name

      } }

      assert_equal({}, assigns[:vip].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'vips', action: 'show', id: Vip.last
  end

  test 'should show vip' do
    get vip_url(@vip)
    assert_response :success
  end

  test 'should get edit' do
    get edit_vip_url(@vip)
    assert_response :success
  end

  test 'should update vip' do
    patch vip_url(@vip), params: { vip: {
      course_category_id: @vip.course_category_id,
      description: @vip.description,
      name: @vip.name

    } }

    assert_equal({}, assigns[:vip].errors.messages.select { |_, v| v.present? })
    assert_redirected_to controller: 'vips', action: 'show', id: @vip
  end

  test 'should destroy vip' do
    assert_difference('Vip.without_deleted.count', -1) do
      @vip.student_billing_details.map(&:really_destroy!)
      delete vip_url(@vip)
      assert_equal({}, assigns[:vip].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'vips', action: :show
  end
end
