# frozen_string_literal: true

class HeaderController < ApplicationController
  responders :flash, :http_cache

  def search
    keyword = params[:keyword]

    return redirect_default(keyword) if keyword.blank?

    if /^[0-9０-９]{9,}+$/.match?(keyword)
      search_telephone(keyword)
    elsif keyword.include?('@')
      search_email(keyword)
    else
      search_name(keyword)
    end
  end

  private

  def redirect_default(keyword)
    flash[:alert] = "「#{keyword}」#{t('controllers.headers.redirect_default(keyword).flash.alert')}" if keyword.present?
    redirect_back(fallback_location: root_path)
  end

  def search_telephone(keyword)
    query = { tel_cont: keyword }
    if Student.ransack(query).result.one?
      student = Student.ransack(query).result.first
      return redirect_to "/students/#{student.id}"
    end
    return redirect_to(students_path(q: query)) if Student.ransack(query).result.exists?

    query = { tel_cont: keyword }
    if Staff.ransack(query).result.one?
      staff = Staff.ransack(query).result.first
      return redirect_to "/staffs/#{staff.id}"
    end
    return redirect_to(staffs_path(q: query)) if Staff.ransack(query).result.exists?

    redirect_default(keyword)
  end

  def search_email(keyword)
    query = { user_email_cont: keyword }
    if Staff.ransack(query).result.one?
      staff = Staff.ransack(query).result.first
      return redirect_to "/staffs/#{staff.id}"
    end
    return redirect_to(staffs_path(q: query)) if Staff.ransack(query).result.exists?

    redirect_default(keyword)
  end

  def search_name(keyword)
    query = { name_or_yomi_or_code_cont: keyword }
    if Student.ransack(query).result.one?
      student = Student.ransack(query).result.first
      return redirect_to "/students/#{student.id}"
    end
    return redirect_to(students_path(q: query)) if Student.ransack(query).result.exists?

    query = { name_or_code_cont: keyword }
    if Staff.ransack(query).result.one?
      staff = Staff.ransack(query).result.first
      return redirect_to "/staffs/#{staff.id}"
    end
    return redirect_to(staffs_path(q: query)) if Staff.ransack(query).result.exists?

    redirect_default(keyword)
  end
end
