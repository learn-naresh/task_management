# app/controllers/tasks_controller.rb
class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  def index
    @tasks = current_user.tasks.or(current_user.assigned_tasks)
    @backlog_tasks = @tasks.where(status: 'backlog')
    @in_progress_tasks = @tasks.where(status: 'in_progress')
    @completed_tasks = @tasks.where(status: 'done')
  end

  def show
    @users = User.all
    respond_to do |format|
      format.json { render json: @task }
      format.html
    end
  end

  def new
    @task = current_user.tasks.build
    @users = User.all
  end

  def create
    @task = current_user.tasks.build(task_params)
    if @task.save
      synchronize_task_event(@task)
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
      render json: @task
    else
      render json: { errors: @task.errors.full_messages }
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

  def synchronize_task_event(task)
    client = Signet::OAuth2::Client.new(client_options)
    client.update!(session[:authorization])
    
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
  
    start_time = task.deadline.beginning_of_day.in_time_zone('Asia/Kolkata').rfc3339
    end_time = (task.deadline.end_of_day.in_time_zone('Asia/Kolkata')).rfc3339
    
    event = Google::Apis::CalendarV3::Event.new(
      summary: task.title,
      description: task.description,
      start: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: start_time,
        time_zone: 'IST'
      ),
      end: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: end_time,
        time_zone: 'IST'
      )
    )
  
    result = service.insert_event('primary', event)
    puts "Event created: #{result.html_link}"  
    
  rescue Google::Apis::AuthorizationError => e
    response = client.refresh!
    session[:authorization] = session[:authorization].merge(response)
    retry
  rescue StandardError => e
    puts "Error creating event: #{e.message}"
  end
end
