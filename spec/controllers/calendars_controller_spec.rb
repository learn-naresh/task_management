require 'rails_helper'

RSpec.describe CalendarsController, type: :controller do
  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in user
  end

  describe 'GET #redirect' do
    it 'redirects to Google authorization URI' do
      get :redirect
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(/https:\/\/accounts\.google\.com\/o\/oauth2\/auth/)
    end
  end

  describe 'GET #callback' do
    let(:mock_client) { instance_double(Signet::OAuth2::Client) }
    let(:mock_response) { { 'access_token' => 'mock_access_token', 'refresh_token' => 'mock_refresh_token' } }

    before do
      allow(Signet::OAuth2::Client).to receive(:new).and_return(mock_client)
      allow(mock_client).to receive(:code=)
      allow(mock_client).to receive(:fetch_access_token!).and_return(mock_response)
    end

    it 'fetches access token and sets session authorization' do
      get :callback, params: { code: 'mock_code' }
      expect(session[:authorization]).to eq(mock_response)
      expect(response).to redirect_to(calendars_path)
    end
  end

  describe 'GET #calendars' do
    let(:mock_client) { instance_double(Signet::OAuth2::Client) }
    let(:mock_service) { instance_double(Google::Apis::CalendarV3::CalendarService) }
    let(:mock_calendar_list) { double('calendar_list') }

    before do
      allow(Signet::OAuth2::Client).to receive(:new).and_return(mock_client)
      allow(mock_client).to receive(:update!)
      allow(Google::Apis::CalendarV3::CalendarService).to receive(:new).and_return(mock_service)
      allow(mock_service).to receive(:authorization=)
      allow(mock_service).to receive(:list_calendar_lists).and_return(mock_calendar_list)
      allow(mock_calendar_list).to receive(:items).and_return([double('calendar_item'), double('calendar_item')])
    end

    it 'fetches and assigns calendar list' do
      session[:authorization] = { 'access_token' => 'mock_access_token' }
      get :calendars
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:calendars)
    end
  end

  describe 'GET #events' do
    let(:mock_client) { instance_double(Signet::OAuth2::Client) }
    let(:mock_service) { instance_double(Google::Apis::CalendarV3::CalendarService) }
    let(:mock_event_list) { double('event_list') }
    let(:calendar_id) { 'mock_calendar_id' }

    before do
      allow(Signet::OAuth2::Client).to receive(:new).and_return(mock_client)
      allow(mock_client).to receive(:update!)
      allow(Google::Apis::CalendarV3::CalendarService).to receive(:new).and_return(mock_service)
      allow(mock_service).to receive(:authorization=)
      allow(mock_service).to receive(:list_events).with("#{calendar_id}.com").and_return(mock_event_list)
      allow(mock_event_list).to receive(:items).and_return([double('event_item'), double('event_item')])
    end

    it 'fetches and assigns event list for a calendar' do
      session[:authorization] = { 'access_token' => 'mock_access_token' }
      get :events, params: { calendar_id: calendar_id }
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:events)
    end
  end
end
