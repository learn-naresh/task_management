require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:tasks) }
    it { should have_many(:assigned_tasks).class_name('Task').with_foreign_key('assigned_user_id') }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
    it { should validate_confirmation_of(:password) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end
end
