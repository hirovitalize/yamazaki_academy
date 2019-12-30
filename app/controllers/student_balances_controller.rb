# frozen_string_literal: true

class StudentBalancesController < ApplicationController
  responders :flash, :http_cache
  before_action :set_student_balance, only: %i[show]
  before_action -> { check_authorize(@student_balance, controller_name) }

  # GET /student_balances
  def index
    @q = StudentBalance.all.order(id: :desc).includes(
      student: :course_categories
    ).ransack(params[:q])

    if params[:export_csv]
      export_csv(@q)
      return
    end

    @student_balances = @q.result.page(params[:page])
    respond_with(@student_balances)
  end

  # GET /student_balances/1
  def show
    respond_with(@student_balance)
  end

  private

  def export_csv(ransackq)
    send_data(
      CsvExportUtil.export(
        ransackq.result(distinct: true),
        header: [
          Student.human_attribute_name(:name),
          Student.human_attribute_name(:code),
          Student.human_attribute_name(:area),
          StudentBillingDetail.model_name.human,
          StudentBalance.human_attribute_name(:price),
          StudentBalance.human_attribute_name(:updated_at)
        ],
        columns: [
          proc { |r| r.student.name },
          proc { |r| r.student.code },
          proc { |r| r.student&.area&.name },
          proc { |r| to_s_student_billing_details(r.student).join(', ') },
          proc { |r| r.price },
          proc { |r| r.updated_at&.to_date }
        ]
      ),
      filename: "売掛金_#{Time.current.strftime('%Y%m%d')}.csv"
    )
  end

  def to_s_student_billing_details(student)
    student.student_billings.map(&:student_billing_details).flatten.map do |detail|
      format(
        '%<me>s%<disc>s',
        me: detail.name,
        disc: (detail.discount&.discount_type.present? ? "<#{detail.discount.discount_type.name}>" : '')
      )
    end
  end

  def set_student_balance
    @student_balance = StudentBalance.with_deleted.find(params[:id])
  end
end
