class ApplicationController < ActionController::Base
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
