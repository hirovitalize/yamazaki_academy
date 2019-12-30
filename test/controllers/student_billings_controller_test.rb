# frozen_string_literal: true

require 'test_helper'

class StudentBillingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @student_billing = student_billings(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'PAYMENT')
  end

  test 'should get index' do
    get student_billings_url
    assert_response :success
  end

  test 'should get new' do
    get new_student_billing_url
    assert_response :success
  end

  test 'should create student_billing' do
    assert_difference('StudentBilling.count') do
      post student_billings_url, params: { student_billing: {
        description: @student_billing.description,
        student_id: @student_billing.student_id,
        total: 50,
        student_billing_details_attributes: { '333' => { item_type: 'Course',
                                                         item_id: 1,
                                                         price: 50 } }
      } }

      assert_equal({}, assigns[:student_billing].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'student_billings', action: 'show', id: StudentBilling.last
  end

  test 'should show student_billing' do
    get student_billing_url(@student_billing)
    assert_response :success
  end

  test 'should get edit' do
    get edit_student_billing_url(@student_billing)
    assert_response :success
  end

  test 'should update student_billing' do
    patch student_billing_url(@student_billing), params: { student_billing: {
      description: @student_billing.description,
      student_id: @student_billing.student_id,
      total: 58_000 + 12_345,
      student_billing_details_attributes: { '1' => { item_type: 'Course',
                                                     item_id: 1,
                                                     price: 58_000 } }
    } }

    assert_equal({}, assigns[:student_billing].errors.messages.select { |_, v| v.present? })
    assert_redirected_to controller: 'student_billings', action: 'show', id: @student_billing
  end

  test 'should destroy student_billing' do
    users(:one).staff.roles.create!(name: 'aaa', code: 'PAYMENT_ADMIN')

    assert_difference('StudentBilling.without_deleted.count', -1) do
      delete student_billing_url(@student_billing)
    end

    assert_redirected_to controller: 'student_billings', action: :show
  end
end
