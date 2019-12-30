# frozen_string_literal: true

class HomeController < ApplicationController
  responders :flash, :http_cache

  def index
    lectures = Lecture.get_home_lectures(current_user.staff.id, Time.zone.now)
    @lecture_time = Lecture.new.time_for_each_month(lectures, current_user.staff.id)
    @lectures = lectures
  end

  def lectures_for_reserves
    lectures = Lecture
               .ransack(
                 start_time_gteq: params[:start_date],
                 finish_time_lteq: params[:end_date],
                 lecture_staffs_staff_id_in: params[:staff_id]
               )
               .result
               .left_outer_joins(:reserve, :subject)
               .select([
                 'lectures.*',
                 'reserves.id as reserve_id',
                 'subjects.id as subject_id',
                 'subjects.personal as personal'
               ].join(',')).uniq

    render json: lectures
  end
end
