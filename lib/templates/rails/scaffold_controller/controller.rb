<% if namespaced? -%>
require_dependency "<%= namespaced_path %>/application_controller"

<% end -%>
<% module_namespacing do -%>
class <%= controller_class_name %>Controller < ApplicationController
  responders :flash, :http_cache
  before_action :set_<%= singular_table_name %>, only: %i[show destroy]
  before_action :init_<%= singular_table_name %>, only: %i[new create]
  before_action :edit_<%= singular_table_name %>, only: %i[edit update]
  before_action -> { check_authorize(@<%= singular_table_name %>, controller_name) }, only: %i[new create edit update destroy]

  # GET <%= route_url %>
  def index
    @q = <%= orm_class.all(class_name) %>.order(id: :desc).ransack(params[:q])
    @<%= plural_table_name %> = @q.result.page(params[:page])
    respond_with(@<%= plural_table_name %>)
  end

  # GET <%= route_url %>/1
  def show
    respond_with(@<%= singular_table_name %>)
  end

  # GET <%= route_url %>/new
  def new
    respond_with(@<%= singular_table_name %>)
  end

  # GET <%= route_url %>/1/edit
  def edit
    respond_with(@<%= singular_table_name %>)
  end

  # POST <%= route_url %>
  def create
    @<%= orm_instance.save %>
    respond_with(@<%= singular_table_name %>)
  end

  # PATCH/PUT <%= route_url %>/1
  def update
    @<%= orm_instance.save %>
    respond_with(@<%= singular_table_name %>)
  end

  # DELETE <%= route_url %>/1
  def destroy
    @<%= orm_instance.destroy %>
    respond_with(@<%= singular_table_name %>, action: :show)
  end

  private

  def set_<%= singular_table_name %>
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]").sub(/find/, 'with_deleted.find') %>
  end

  def init_<%= singular_table_name %>
    attributes = params[:<%= singular_table_name %>].blank? ? {} : <%= "#{singular_table_name}_params" %>
    @<%= singular_table_name %> = <%= orm_class.build(class_name) %> attributes
  end

  def edit_<%= singular_table_name %>
    set_<%= singular_table_name %>
    return if params[:<%= singular_table_name %>].blank?

    @<%= singular_table_name %>.attributes = <%= "#{singular_table_name}_params" %>
  end

  def <%= "#{singular_table_name}_params" %>
    params.require(:<%= singular_table_name %>).permit!
  end
end
<% end -%>
