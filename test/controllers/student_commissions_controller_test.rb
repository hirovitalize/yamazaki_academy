# frozen_string_literal: true

require 'test_helper'

class StudentCommissionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @student_commission = student_commissions(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'PAYMENT')
  end

  test 'should get index' do
    get student_commissions_url
    assert_response :success
  end

  test 'should get new' do
    get new_student_commission_url
    assert_response :success
  end

  test 'should create student_commission' do
    assert_difference('StudentCommission.count') do
      post student_commissions_url, params: { student_commission: {
        cache_back_type_id: @student_commission.cache_back_type_id,
        description: @student_commission.description,
        referral: @student_commission.referral,
        price: @student_commission.price,
        inflow_source_id: @student_commission.inflow_source_id,
        student_id: @student_commission.student_id
      } }

      assert_equal({}, assigns[:student_commission].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'student_commissions', action: 'show', id: StudentCommission.last
  end

  test 'should show student_commission' do
    get student_commission_url(@student_commission)
    assert_response :success
  end

  test 'should get edit' do
    get edit_student_commission_url(@student_commission)
    assert_response :success
  end

  test 'should update student_commission' do
    patch student_commission_url(@student_commission), params: { student_commission: {
      cache_back_type_id: @student_commission.cache_back_type_id,
      description: @student_commission.description,
      referral: @student_commission.referral,
      price: @student_commission.price,
      inflow_source_id: @student_commission.inflow_source_id,
      student_id: @student_commission.student_id
    } }

    assert_equal({}, assigns[:student_commission].errors.messages.select { |_, v| v.present? })
    assert_redirected_to controller: 'student_commissions', action: 'show', id: @student_commission
  end

  test 'should destroy student_commission' do
    users(:one).staff.roles.create!(name: 'aaa', code: 'PAYMENT_ADMIN')

    assert_difference('StudentCommission.without_deleted.count', -1) do
      delete student_commission_url(@student_commission)
    end

    assert_redirected_to controller: 'student_commissions', action: :show
  end
end
