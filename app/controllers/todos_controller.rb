class TodosController < ApplicationController
  include Pagy::Method
  before_action :set_todo, only: %i[ edit update destroy ]

  def index
    @pagy, @todos = pagy(Todo.recent_first, items: 20)

    if turbo_frame_request?
      render partial: 'todos/frame', locals: { view_models: @todos, pagy: @pagy }
    end
  end

  def new
    @todo = Todo.new
  end

  def create
    @todo = Todo.new(todo_params)

    if @todo.save
      redirect_to user_todos_path(Current.user), notice: 'Todo was successfully created.'
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @todo.update(todo_params)
      redirect_to user_todos_path(Current.user), notice: 'Todo was successfully updated.', status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @todo.destroy!
    redirect_to user_todos_path(Current.user), notice: 'Todo was successfully destroyed.', status: :see_other
  end

  private
    def set_todo
      @todo = Todo.find(params.expect(:id))
    end

    def todo_params
      params.expect(todo: [ :title, :details, :completed ])
    end
end
