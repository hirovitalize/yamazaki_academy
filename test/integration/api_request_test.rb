# frozen_string_literal: true

require 'test_helper'

class ApiRequestTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @user.regenerate_auth_token
    sign_in @user
    @headers = { 'X-Access-Token' => @user.auth_token }
  end

  ApplicationRecord.descendants.each do |model|
    base_url = "/api/v1/#{model.table_name}"

    test "#{model} without auth" do
      get base_url + '.json'
      result = JSON.parse(response.body)
      assert_instance_of Hash, result, "when #{response.status}"
      assert_response :unauthorized
    end
    # TODO: select/order/pagenateのテスト

    test "#{model} ransack条件" do
      get base_url + '.json?q[id_in]=1&q[id_in]=2&q[s]=updated_at desc&select[]=id&page=1&per2',
          params: {}, headers: @headers
      result = JSON.parse(response.body)
      assert_instance_of Array, result, "when #{response.status}"
      assert_response :success
    end

    test "#{model} counts" do
      get base_url + '/count.json', as: :json, params: {}, headers: @headers
      result = JSON.parse(response.body)
      assert_instance_of Integer, result, "when #{response.status}"
      assert_response :success
    end

    test "#{model} list" do
      get base_url + '.json?page=1&per=100', params: {}, headers: @headers
      result = JSON.parse(response.body)
      assert_instance_of Array, result, "when #{response.status}"
      assert_response :success
    end

    test "#{model} create" do
      post base_url + '.json', params: { model.to_s => { name: 'aaa' } }, headers: @headers
      result = JSON.parse(response.body)
      assert_instance_of Hash, result, "when #{response.status}"
      flunk result if response.status == 500
      assert_includes [201, 400], response.status # success, invalid
    end

    test "#{model} id=99999999" do
      get base_url + '/99999999.json', params: {}, headers: @headers
      result = JSON.parse(response.body)
      assert_instance_of Hash, result, "when #{response.status}"
      flunk result if response.status == 500
      assert_response :not_found
    end

    test "#{model} update" do
      put base_url + '/1.json', params: { model.to_s => { name: 'aaa' } }, headers: @headers
      result = JSON.parse(response.body)
      if response.status == 200
        assert_instance_of TrueClass, result
      else # 404, 400
        assert_instance_of Hash, result, "when #{response.status}"
      end
      flunk result if response.status == 500
      assert_includes [200, 404, 400], response.status # success, not_found, invalid
    end

    test "#{model} delete" do
      delete base_url + '/1.json', params: {}, headers: @headers
      result = JSON.parse(response.body)
      assert_instance_of Hash, result, "when #{response.status}"
      flunk result if response.status == 500
      assert_includes [203, 404, 200, 400], response.status # success, not_found, ok, invalid
    end
  end
end
