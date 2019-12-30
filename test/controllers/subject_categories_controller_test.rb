# frozen_string_literal: true

require 'test_helper'

class SubjectCategoriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @subject_category = subject_categories(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'MASTER_CONTROL')
  end

  test 'should get index' do
    get subject_categories_url
    assert_response :success
  end

  test 'should get new' do
    get new_subject_category_url
    assert_response :success
  end

  test 'should create subject_category' do
    assert_difference('SubjectCategory.count') do
      post subject_categories_url, params: { subject_category: {
        description: @subject_category.description,
        name: @subject_category.name,
        code: @subject_category.code
      } }

      assert_equal({}, assigns[:subject_category].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'subject_categories', action: 'show', id: SubjectCategory.last
  end

  test 'should show subject_category' do
    get subject_category_url(@subject_category)
    assert_response :success
  end

  test 'should get edit' do
    get edit_subject_category_url(@subject_category)
    assert_response :success
  end

  test 'should update subject_category' do
    patch subject_category_url(@subject_category), params: { subject_category: {
      description: @subject_category.description,
      name: @subject_category.name

    } }

    assert_equal({}, assigns[:subject_category].errors.messages.select { |_, v| v.present? })
    assert_redirected_to controller: 'subject_categories', action: 'show', id: @subject_category
  end

  test 'should destroy subject_category' do
    @subject_category.subjects.map(&:really_destroy!)
    assert_difference('SubjectCategory.without_deleted.count', -1) do
      delete subject_category_url(@subject_category)
    end

    assert_redirected_to controller: 'subject_categories', action: :show
  end
end
