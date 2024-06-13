require 'rails_helper'

RSpec.describe "Calendars", type: :request do
  describe "GET /redirect" do
    it "returns http success" do
      get "/calendars/redirect"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /callback" do
    it "returns http success" do
      get "/calendars/callback"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /calendars" do
    it "returns http success" do
      get "/calendars/calendars"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /events" do
    it "returns http success" do
      get "/calendars/events"
      expect(response).to have_http_status(:success)
    end
  end

end
