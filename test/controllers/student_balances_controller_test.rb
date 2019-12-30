# frozen_string_literal: true

require 'test_helper'

class StudentBalancesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @student_balance = student_balances(:one)
    sign_in users(:one)
  end

  test 'should get index' do
    get student_balances_url
    assert_response :success
  end

  test 'should get new' do
    assert_raise(NameError) do
      get new_student_balance_url
    end
  end

  test 'should create student_balance' do
    assert_raise(ActionController::RoutingError) do
      post student_balances_url
    end
  end

  test 'should show student_balance' do
    get student_balance_url(@student_balance)
    assert_response :success
  end

  test 'should get edit' do
    assert_raise(NoMethodError) do
      get edit_student_balance_url(@student_balance)
    end
  end

  test 'should update student_balance' do
    assert_raise(ActionController::RoutingError) do
      patch student_balance_url(@student_balance)
    end
  end

  test 'should destroy student_balance' do
    assert_raise(ActionController::RoutingError) do
      delete student_balance_url(@student_balance)
    end
  end
end
