# app/jobs/reminder_job.rb
class ReminderJob < ApplicationJob
  queue_as :default

  def perform(task_id)
    task = Task.find(task_id)
    TaskMailer.deadline_reminder(task).deliver_now if task.deadline > Time.now && task.status != 'done'
  end
end
