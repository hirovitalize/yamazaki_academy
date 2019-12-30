# frozen_string_literal: true

require 'test_helper'

class StudentPaymentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @student_payment = student_payments(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'PAYMENT')
  end

  test 'should get index' do
    get student_payments_url
    assert_response :success
  end

  test 'should get new' do
    get new_student_payment_url
    assert_response :success
  end

  test 'should create student_payment' do
    assert_difference('StudentPayment.count') do
      post student_payments_url, params: { student_payment: {
        description: @student_payment.description,
        pay_date: @student_payment.pay_date,
        paymethod_id: @student_payment.paymethod_id,
        price: @student_payment.price,
        gen: @student_payment.gen,
        receiver_id: @student_payment.receiver_id,
        student_id: @student_payment.student_id
      } }

      assert_equal({}, assigns[:student_payment].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'student_payments', action: 'show', id: StudentPayment.last
  end

  test 'should show student_payment' do
    get student_payment_url(@student_payment)
    assert_response :success
  end

  test 'should get edit' do
    get edit_student_payment_url(@student_payment)
    assert_response :success
  end

  test 'should update student_payment' do
    patch student_payment_url(@student_payment), params: { student_payment: {
      description: @student_payment.description,
      pay_date: @student_payment.pay_date,
      paymethod_id: @student_payment.paymethod_id,
      price: @student_payment.price,
      gen: @student_payment.gen,
      receiver_id: @student_payment.receiver_id,
      student_id: @student_payment.student_id
    } }

    assert_equal({}, assigns[:student_payment].errors.messages.select { |_, v| v.present? })
    assert_redirected_to controller: 'student_payments', action: 'show', id: @student_payment
  end

  test 'should destroy student_payment' do
    users(:one).staff.roles.create!(name: 'aaa', code: 'PAYMENT_ADMIN')

    assert_difference('StudentPayment.without_deleted.count', -1) do
      delete student_payment_url(@student_payment)
    end

    assert_redirected_to controller: 'student_payments', action: :show
  end
end
