require 'rails_helper'

RSpec.describe TasksController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:task) { FactoryBot.create(:task, user: user) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'assigns tasks to backlog, in_progress, and completed categories' do
      task_backlog = FactoryBot.create(:task, user: user, status: 'backlog')
      task_in_progress = FactoryBot.create(:task, user: user, status: 'in_progress')
      task_completed = FactoryBot.create(:task, user: user, status: 'done')

      get :index
      expect(assigns(:backlog_tasks)).to include(task_backlog)
      expect(assigns(:in_progress_tasks)).to include(task_in_progress)
      expect(assigns(:completed_tasks)).to include(task_completed)
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'GET #show' do
    it 'assigns the requested task' do
      get :show, params: { id: task.id }
      expect(assigns(:task)).to eq(task)
    end

    it 'renders the show template' do
      get :show, params: { id: task.id }
      expect(response).to render_template('show')
    end
  end

  describe 'GET #new' do
    it 'assigns a new task' do
      get :new
      expect(assigns(:task)).to be_a_new(Task)
    end

    it 'renders the new template' do
      get :new
      expect(response).to render_template('new')
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:valid_attributes) { FactoryBot.attributes_for(:task, user: user) }

      it 'creates a new task' do
        expect {
          post :create, params: { task: valid_attributes }
        }.to change(Task, :count).by(1)
      end

      it 'redirects to the created task' do
        post :create, params: { task: valid_attributes }
        expect(response).to redirect_to(Task.last)
      end
    end

    context 'with invalid params' do
      let(:invalid_attributes) { FactoryBot.attributes_for(:task, title: nil, user: user) }

      it 'does not create a new task' do
        expect {
          post :create, params: { task: invalid_attributes }
        }.to_not change(Task, :count)
      end

      it 're-renders the new template' do
        post :create, params: { task: invalid_attributes }
        expect(response).to render_template('new')
      end
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested task' do
      get :edit, params: { id: task.id }
      expect(assigns(:task)).to eq(task)
    end

    it 'renders the edit template' do
      get :edit, params: { id: task.id }
      expect(response).to render_template('edit')
    end
  end

  describe 'PATCH #update' do
    context 'with valid params' do
      let(:new_attributes) { { title: 'Updated Title' } }

      it 'updates the requested task' do
        patch :update, params: { id: task.id, task: new_attributes }
        task.reload
        expect(task.title).to eq('Updated Title')
      end

      it 'renders the updated task as JSON' do
        patch :update, params: { id: task.id, task: new_attributes }, format: :json
        expect(JSON.parse(response.body)['title']).to eq('Updated Title')
      end
    end

    context 'with invalid params' do
      let(:invalid_attributes) { { title: nil } }

      it 'does not update the task' do
        old_title = task.title
        patch :update, params: { id: task.id, task: invalid_attributes }
        task.reload
        expect(task.title).to eq(old_title)
      end

      it 'renders errors as JSON' do
        patch :update, params: { id: task.id, task: invalid_attributes }, format: :json
        expect(JSON.parse(response.body)).to have_key('errors')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested task' do
      task_to_delete = FactoryBot.create(:task, user: user)
      expect {
        delete :destroy, params: { id: task_to_delete.id }
      }.to change(Task, :count).by(-1)
    end

    it 'redirects to the tasks list' do
      delete :destroy, params: { id: task.id }
      expect(response).to redirect_to(tasks_url)
    end
  end

  describe 'synchronize_task_event' do
    let(:task) { FactoryBot.create(:task, user: user, deadline: Time.now + 1.day) }

    it 'synchronizes task event with Google Calendar' do
      allow_any_instance_of(Signet::OAuth2::Client).to receive(:update!)
      allow_any_instance_of(Google::Apis::CalendarV3::CalendarService).to receive(:insert_event)

      expect_any_instance_of(Google::Apis::CalendarV3::CalendarService).to receive(:insert_event).once

      controller.send(:synchronize_task_event, task)
    end
  end
end
