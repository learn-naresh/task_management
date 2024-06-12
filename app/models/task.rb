# app/models/task.rb
class Task < ApplicationRecord
  belongs_to :user

  belongs_to :assigned_user, class_name: 'User', optional: true


  validates :title, :status, :deadline, presence: true

  enum status: { backlog: 'backlog', in_progress: 'in_progress', done: 'done' }

  # after_create :schedule_reminders

  private

  def schedule_reminders
    ReminderJob.set(wait_until: deadline - 1.day).perform_later(self.id)
    ReminderJob.set(wait_until: deadline - 1.hour).perform_later(self.id)
  end

end
