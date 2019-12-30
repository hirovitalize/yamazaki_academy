# frozen_string_literal: true

require 'test_helper'

class StudentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @student = students(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'STUDENT_ADMIN')
  end

  test 'should get index' do
    get students_url
    assert_response :success
  end

  test 'should get new' do
    get new_student_url
    assert_response :success
  end

  test 'should create student' do
    assert_difference('Student.count') do
      post students_url, params: { student: {
        qq: @student.qq,
        wechat: @student.wechat,
        area_id: @student.area_id,
        name: @student.name,
        name_sei: @student.name_sei,
        name_mei: @student.name_mei,
        yomi: @student.yomi,
        yomi_sei: @student.yomi_sei,
        yomi_mei: @student.yomi_mei,
        # code: 自動生成で別番振る
        sex: :male,
        tel: @student.tel,
        visa_type: @student.visa_type,
        contracted_at: @student.contracted_at
      } }

      assert_equal({}, assigns[:student].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'students', action: 'show', id: Student.last
  end

  test 'should show student' do
    get student_url(@student)
    assert_response :success
  end

  test 'should get edit' do
    get edit_student_url(@student)
    assert_response :success
  end

  test 'should get choose_merging' do
    get choose_merging_student_url(@student)
    assert_response :success
  end

  test 'should change_normalized student' do
    post change_normalized_student_url(@student)

    assert_equal true, assigns[:student].normalized
  end

  test 'should get compare_merging' do
    @similar_student = students(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'STUDENT_ADMIN')

    get compare_merging_student_url(@student, target_student_id: @similar_student.id)

    assert_response :success
  end

  test 'should merge student' do
    @master_student = students(:two)

    assert_difference('Student.without_deleted.count', -1) do
      post merge_student_url(@student, target_student_id: @master_student.id)
    end

    assert_equal @student.code, assigns[:master_student].merged_codes
  end

  test 'should update student' do
    patch student_url(@student), params: { student: {
      qq: @student.qq,
      wechat: @student.wechat,
      area_id: @student.area_id,
      name: @student.name,
      name_sei: @student.name_sei,
      name_mei: @student.name_mei,
      yomi: @student.yomi,
      yomi_sei: @student.yomi_sei,
      yomi_mei: @student.yomi_mei,
      code: @student.code,
      sex: :female,
      tel: @student.tel,
      visa_type: @student.visa_type,
      contracted_at: @student.contracted_at
    } }

    assert_equal({}, assigns[:student].errors.messages.select { |_, v| v.present? })
    assert_redirected_to controller: 'students', action: 'show', id: @student
  end

  test 'should destroy student' do
    @student.lecture_students.map(&:really_destroy!)
    @student.klass_students.map(&:really_destroy!)
    @student.student_mentors.map(&:really_destroy!)
    @student.student_point.destroy
    assert_difference('Student.without_deleted.count', -1) do
      delete student_url(@student)
    end

    assert_redirected_to controller: 'students', action: :show
  end
end
