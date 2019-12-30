# frozen_string_literal: true

require 'test_helper'

<% module_namespacing do -%>
class <%= controller_class_name %>ControllerTest < ActionDispatch::IntegrationTest
  <%- if mountable_engine? -%>
  include Engine.routes.url_helpers
  <%- end -%>
  include Devise::Test::IntegrationHelpers

  <%- skipping_fields = %w[id creator_id created_at updater_id updated_at deleter_id deleted_at] -%>
  setup do
    @<%= singular_table_name %> = <%= fixture_name %>(:one)
    sign_in users(:one)
  end

  test 'should get index' do
    get <%= index_helper %>_url
    assert_response :success
  end

  test 'should get new' do
    get <%= new_helper %>
    assert_response :success
  end

  test 'should create <%= singular_table_name %>' do
    assert_difference('<%= class_name %>.count') do
      post <%= index_helper %>_url, params: { <%= "#{singular_table_name}: {" %>
<% attributes_hash.except(*skipping_fields).each do |field, row| -%>
        <%= "#{field}: #{row}," %>
<% end %>
      <%= '}' %> }

      assert_equal({}, assigns[:<%= singular_table_name %>].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: '<%= singular_table_name.pluralize %>', action: 'show', id: <%= class_name %>.last
  end

  test 'should show <%= singular_table_name %>' do
    get <%= show_helper %>
    assert_response :success
  end

  test 'should get edit' do
    get <%= edit_helper %>
    assert_response :success
  end

  test 'should update <%= singular_table_name %>' do
    patch <%= show_helper %>, params: { <%= "#{singular_table_name}: {" %>
<% attributes_hash.except(*skipping_fields).each do |field, row| -%>
      <%= "#{field}: #{row}," %>
<% end %>
    <%= '}' %> }

    assert_equal({}, assigns[:<%= singular_table_name %>].errors.messages.select { |_, v| v.present? })
    assert_redirected_to controller: '<%= singular_table_name.pluralize %>', action: 'show', id: <%= "@#{singular_table_name}" %>
  end

  <%- paranoided = class_name.constantize.respond_to?(:without_deleted) -%>
  <%- count_scope = paranoided ? 'without_deleted.count' : 'count' -%>
  test 'should destroy <%= singular_table_name %>' do
    assert_difference('<%= class_name %>.<%= count_scope %>', -1) do
      delete <%= show_helper %>
      assert_equal({}, assigns[:<%= singular_table_name %>].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: '<%= singular_table_name.pluralize %>', action: :show
  end
end
<% end -%>
