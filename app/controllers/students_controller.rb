# frozen_string_literal: true

class StudentsController < ApplicationController
  responders :flash, :http_cache
  before_action :set_student, only: %i[show destroy choose_merging change_normalized compare_merging merge]
  before_action :init_student, only: %i[new create]
  before_action :edit_student, only: %i[edit update]
  before_action -> { check_authorize(@student, controller_name) },
                only: %i[new create edit update destroy choose_merging change_normalized compare_merging merge]

  # GET /students
  def index
    @q = Student.all.order(id: :desc).includes(
      :course_categories,
      :student_mycoach
    ).ransack(params[:q])
    @students = @q.result.page(params[:page])
    respond_with(@students)
  end

  # GET /students/1
  def show
    respond_with(@student)
  end

  # GET /students/new
  def new
    @student.build_student_mycoach
    respond_with(@student)
  end

  # GET /students/1/edit
  def edit
    @student.build_student_mycoach if @student.student_mycoach.blank?
    respond_with(@student)
  end

  # POST /students
  def create
    @student.normalized = true if @student.similar_students.blank?
    @student.save
    respond_with(@student)
  end

  # PATCH/PUT /students/1
  def update
    @student.save
    respond_with(@student)
  end

  # DELETE /students/1
  def destroy
    @student.student_mycoach.destroy if @student.student_mycoach.present?
    @student.destroy
    respond_with(@student, action: :show)
  end

  def choose_merging
    @similar_students = @student.similar_students
  end

  def change_normalized
    @student.update(normalized: true)
    respond_with(@student)
  end

  def compare_merging
    @master_student = Student.find(params[:target_student_id])
  end

  def merge
    @master_student = Student.find(params[:target_student_id])
    begin
      ActiveRecord::Base.transaction do
        @student.merge_into!(@master_student)
      end
      flash[:notice] = "学籍番号#{@student.code}の#{@student.name}をマージしました"
    rescue StandardError
      flash[:alert] = "学籍番号#{@student.code}の#{@student.name}はマージ失敗しました。"
    end
    respond_with(@master_student)
  end

  def import
    if params[:csv_file].blank?
      redirect_to(students_url, alert: 'インポートするCSVファイルを選択してください')
      return
    end

    text_lines = File.open(params[:csv_file].path).readlines
    import_result = []
    begin
      ActiveRecord::Base.transaction do
        import_result = Student.import_text_lines(text_lines)
      end
    rescue StandardError => e
      return redirect_to(students_url, alert: e)
    end

    if import_result[0] == true
      imported_students = import_result[1]
      notice_message = "#{imported_students.count}名の学生情報をインポートしました。"
      redirect_to(students_url, notice: notice_message)
    else
      error_row_number = import_result[2]
      validation_message = import_result[3].errors.full_messages
      alert_message = if validation_message.blank?
                        "ファイルの#{error_row_number}行目で例外エラーが発生したため、インポートを中止しました。"
                      else
                        'データ不正のためファイルのインポートに失敗しました。 '\
                                + "#{error_row_number}行目の次の項目を確認してください。#{validation_message}"
                      end
      redirect_to(
        students_url,
        alert: alert_message
      )
    end
  end

  private

  def set_student
    @student = Student.with_deleted.find(params[:id])
  end

  def init_student
    attributes = params[:student].blank? ? {} : student_params
    @student = Student.new attributes
  end

  def edit_student
    set_student
    return if params[:student].blank?

    @student.attributes = student_params
  end

  def student_params
    params.require(:student).permit!
  end
end
