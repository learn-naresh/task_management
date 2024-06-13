require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:assigned_user).class_name('User').optional }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:deadline) }
  end

  describe 'callbacks' do
    let(:task) { FactoryBot.build(:task) }

    it 'schedules reminders after create' do
      allow(ReminderJob).to receive(:set).and_return(ReminderJob)
      expect(ReminderJob).to receive(:set).with(wait_until: task.deadline - 1.day).once
      expect(ReminderJob).to receive(:set).with(wait_until: task.deadline - 1.hour).once
      task.save
    end
  end
end
