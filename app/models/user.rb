class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :tasks
  has_many :assigned_tasks, class_name: 'Task', foreign_key: 'assigned_user_id'
end
