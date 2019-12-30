# frozen_string_literal: true

require 'test_helper'

class KlassTemplatesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @klass_template = klass_templates(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'MASTER_CONTROL')
  end

  test 'should get index' do
    get klass_templates_url
    assert_response :success
  end

  test 'should get new' do
    get new_klass_template_url
    assert_response :success
  end

  test 'should create klass_template' do
    assert_difference('KlassTemplate.count') do
      post klass_templates_url, params: { klass_template: {
        description: @klass_template.description,
        name: @klass_template.name,
        course_category_id: @klass_template.course_category_id,
        lecture_num: @klass_template.lecture_num,
        interval: @klass_template.interval
      } }

      assert_equal({}, assigns[:klass_template].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'klass_templates', action: 'show', id: KlassTemplate.last
  end

  test 'should show klass_template' do
    get klass_template_url(@klass_template)
    assert_response :success
  end

  test 'should get edit' do
    get edit_klass_template_url(@klass_template)
    assert_response :success
  end

  test 'should update klass_template' do
    patch klass_template_url(@klass_template), params: { klass_template: {
      description: @klass_template.description,
      name: @klass_template.name,
      course_category_id: @klass_template.course_category_id,
      lecture_num: @klass_template.lecture_num,
      interval: @klass_template.interval
    } }

    assert_equal({}, assigns[:klass_template].errors.messages.select { |_, v| v.present? })
    assert_redirected_to controller: 'klass_templates', action: 'show', id: @klass_template
  end

  test 'should destroy klass_template' do
    @klass_template.klass_template_subjects.map(&:really_destroy!)
    @klass_template.klasses.map(&:really_destroy!)
    assert_difference('KlassTemplate.without_deleted.count', -1) do
      delete klass_template_url(@klass_template)
    end

    assert_redirected_to controller: 'klass_templates', action: :show
  end
end
