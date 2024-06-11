# Task Management Application

This is a task management application built with Ruby on Rails and PostgreSQL.

## Features

- User authentication
- Create, update, delete tasks
- Task statuses: Backlog, In-progress, Done
- Task deadlines with email reminders
- Responsive UI

## Setup

1. Clone the repository.
2. Install dependencies: `bundle install`
3. Set up the database: `rails db:create db:migrate`
4. Start the server: `rails server`

## Testing

Run tests with: `rspec`

## Dependencies

- Ruby on Rails
- PostgreSQL
- Devise for authentication
- Sidekiq and Redis for background jobs
