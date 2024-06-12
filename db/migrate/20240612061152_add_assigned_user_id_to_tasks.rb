class AddAssignedUserIdToTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :assigned_user_id, :bigint
    add_index :tasks, :assigned_user_id
  end
end
