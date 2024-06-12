# app/controllers/tasks_controller.rb
class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  def index
    @tasks = current_user.tasks.or(current_user.assigned_tasks)
  end

  def show
  end

  def new
    @task = current_user.tasks.build
    @users = User.all
  end

  def create
    @task = current_user.tasks.build(task_params)
    if @task.save
      redirect_to @task, notice: 'Task was successfully created.'
    else
      @users = User.all
      render :new
    end
  end

  def edit
    @users = User.all
  end

  def update
    if @task.update(task_params)
      redirect_to @task, notice: 'Task was successfully updated.'
    else
      @users = User.all
      render :edit
    end
  end

  def destroy
    @task.destroy
    redirect_to tasks_url, notice: 'Task was successfully destroyed.'
  end

  private

  def set_task
    @task = current_user.tasks.or(current_user.assigned_tasks).find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :status, :deadline, :assigned_user_id)
  end
end
