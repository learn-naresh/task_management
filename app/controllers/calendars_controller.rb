# app/controllers/calendars_controller.rb

class CalendarsController < ApplicationController
  def redirect
    client = Signet::OAuth2::Client.new(client_options)
    redirect_to client.authorization_uri.to_s, allow_other_host: true
  end

  def callback
    client = Signet::OAuth2::Client.new(client_options)
    client.code = params[:code]
    response = client.fetch_access_token!
    session[:authorization] = response
    redirect_to calendars_path
  end

  def calendars
    client = Signet::OAuth2::Client.new(client_options)
    client.update!(session[:authorization])
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
    @calendar_list = service.list_calendar_lists
    puts @calendar_list
  end

  def events
    client = Signet::OAuth2::Client.new(client_options)
    client.update!(session[:authorization])
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
    @event_list = service.list_events(params[:calendar_id] + '.com')
  rescue Google::Apis::AuthorizationError
    response = client.refresh!
    session[:authorization] = session[:authorization].merge(response)
    retry
  end

  private

  def client_options
    {
      client_id: ENV.fetch('GOOGLE_CLIENT_ID'),
      client_secret: ENV.fetch('GOOGLE_CLIENT_SECRET'),
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
      redirect_uri: callback_url
    }
  end

  def callback_url
    root_url(host: request.host_with_port, protocol: request.protocol) + 'callback'
  end
end
