# frozen_string_literal: true

require 'test_helper'

class BooksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @book = books(:one)
    sign_in users(:one)
    users(:one).staff.roles.create!(name: 'aaa', code: 'MASTER_CONTROL')
  end

  test 'should get index' do
    get books_url
    assert_response :success
  end

  test 'should get new' do
    get new_book_url
    assert_response :success
  end

  test 'should create book' do
    assert_difference('Book.count') do
      post books_url, params: { book: {
        description: @book.description,
        name: @book.name,
        price: @book.price

      } }

      assert_equal({}, assigns[:book].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'books', action: 'show', id: Book.last
  end

  test 'should show book' do
    get book_url(@book)
    assert_response :success
  end

  test 'should get edit' do
    get edit_book_url(@book)
    assert_response :success
  end

  test 'should update book' do
    patch book_url(@book), params: { book: {
      description: @book.description,
      name: @book.name,
      price: @book.price,
      isbn: @book.isbn

    } }

    assert_equal({}, assigns[:book].errors.messages.select { |_, v| v.present? })
    assert_redirected_to controller: 'books', action: 'show', id: @book
  end

  test 'should destroy book' do
    assert_difference('Book.without_deleted.count', -1) do
      delete book_url(@book)
      assert_equal({}, assigns[:book].errors.messages.select { |_, v| v.present? })
    end

    assert_redirected_to controller: 'books', action: :show
  end
end
