# frozen_string_literal: true

class BooksController < ApplicationController
  responders :flash, :http_cache
  before_action :set_book, only: %i[show destroy]
  before_action :init_book, only: %i[new create]
  before_action :edit_book, only: %i[edit update]
  before_action -> { check_authorize(@book, controller_name) }, only: %i[new create edit update destroy]

  # GET /books
  def index
    @q = Book.all.order(id: :desc).ransack(params[:q])
    @books = @q.result.page(params[:page])
    respond_with(@books)
  end

  # GET /books/1
  def show
    respond_with(@book)
  end

  # GET /books/new
  def new
    respond_with(@book)
  end

  # GET /books/1/edit
  def edit
    respond_with(@book)
  end

  # POST /books
  def create
    @book.save
    respond_with(@book)
  end

  # PATCH/PUT /books/1
  def update
    @book.save
    respond_with(@book)
  end

  # DELETE /books/1
  def destroy
    @book.destroy
    respond_with(@book, action: :show)
  end

  private

  def set_book
    @book = Book.with_deleted.find(params[:id])
  end

  def init_book
    attributes = params[:book].blank? ? {} : book_params
    @book = Book.new attributes
  end

  def edit_book
    set_book
    return if params[:book].blank?

    @book.attributes = book_params
  end

  def book_params
    params.require(:book).permit!
  end
end
