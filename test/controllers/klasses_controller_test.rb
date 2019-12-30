# frozen_string_literal: true

require 'test_helper'

class KlassesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @klass = klasses(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'MASTER_CONTROL')
  end

  test 'should get index' do
    get klasses_url
    assert_response :success
  end

  test 'should get new' do
    get new_klass_url
    assert_response :success
  end

  test 'should create klass' do
    assert_difference('Klass.count') do
      post klasses_url, params: { klass: {
        description: @klass.description,
        name: @klass.name,
        code: @klass.code,
        klass_template_id: @klass.klass_template_id,
        area_id: @klass.area_id,
        start_date: @klass.start_date,
        finish_date: @klass.finish_date
      } }

      assert_equal({}, assigns[:klass].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'klasses', action: 'show', id: Klass.last
  end

  test 'should show klass' do
    get klass_url(@klass)
    assert_response :success
  end

  test 'should curriculum klass' do
    get curriculum_klass_url(@klass)
    assert_response :success
  end

  test 'should curriculum_schedule klass' do
    get curriculum_schedule_klass_url(:json, start_date: Time.zone.today, end_date: Time.zone.today + 1.day, id: @klass.id)
    assert_response :success
  end

  test 'should get edit' do
    get edit_klass_url(@klass)
    assert_response :success
  end

  test 'should update klass' do
    patch klass_url(@klass), params: { klass: {
      description: @klass.description,
      name: @klass.name,
      klass_template_id: @klass.klass_template_id,
      area_id: @klass.area_id,
      lecture_num: @klass.lecture_num,
      interval: @klass.interval,
      start_date: @klass.start_date,
      finish_date: @klass.finish_date
    } }

    assert_equal({}, assigns[:klass].errors.messages.select { |_, v| v.present? })
    assert_redirected_to controller: 'klasses', action: 'show', id: @klass
  end

  test 'should destroy klass' do
    @klass.klass_students.map(&:really_destroy!)
    @klass.klass_subjects.map(&:really_destroy!)
    assert_difference('Klass.without_deleted.count', -1) do
      delete klass_url(@klass)
    end

    assert_redirected_to controller: 'klasses', action: :show
  end
end
