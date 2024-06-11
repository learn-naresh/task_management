# app/mailers/task_mailer.rb
class TaskMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def deadline_reminder(task)
    @task = task
    mail(to: @task.user.email, subject: 'Task Deadline Reminder')
  end
end
