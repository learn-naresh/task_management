FactoryBot.define do
  factory :task do
    sequence(:title) { |n| "Task #{n}" }
    status { Task.statuses.keys.sample }
    deadline { Faker::Time.forward(days: 10) }
    user

    trait :with_assigned_user do
      assigned_user { association :user }
    end
  end
end
  