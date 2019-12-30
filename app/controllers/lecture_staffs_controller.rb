# frozen_string_literal: true

class LectureStaffsController < ApplicationController
  responders :flash, :http_cache
  before_action :set_lecture_staff, only: %i[show]
  before_action -> { check_authorize(@lecture_staff, controller_name) }, only: %i[index show]

  # GET /lecture_staffs
  def index
    @q = LectureStaff.all.includes(:staff, :lecture, :work_kind).order(id: :desc).ransack(params[:q])
    if params[:export_csv]
      export_csv(@q)
      return
    end

    @lecture_staffs = @q.result.page(params[:page])
    respond_with(@lecture_staffs)
  end

  # GET /lecture_staffs/1
  def show
    respond_with(@lecture_staff)
  end

  private

  def export_csv(ransackq)
    send_data(
      CsvExportUtil.export(
        ransackq.result(distinct: true).includes(:lecture, :staff, :work_kind),
        header: %w[ID 給与時間数 授業 開始日時 終了日時 社員名 社員番号 業務種別 科目 キャンセル種別],
        columns: %i[id confirmed_staff_hours] +
         [proc { |r| r.lecture.try(:name) }] +
         [proc { |r| r.start_time }] +
         [proc { |r| r.finish_time }] +
         [proc { |r| r.staff.try(:name) }] +
         [proc { |r| r.staff.try(:code) }] +
         [proc { |r| r.work_kind.try(:name) }] +
         [proc { |r| r.lecture&.subject.try(:name) }] +
         [proc { |r| r.lecture.try(:canceled_status_i18n) }]
      ),
      filename: "給与データ#{Time.current.strftime('%Y%m%d')}.csv"
    )
  end

  def set_lecture_staff
    @lecture_staff = LectureStaff.with_deleted.find(params[:id])
  end
end
