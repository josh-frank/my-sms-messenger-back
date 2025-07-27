class ApplicationController < ActionController::API

  helper_method :current_user, :authenticate_jwt, :authorize
  before_action :authenticate_jwt, except: [ :about ]
  before_action :authorize, except: [ :about ]

  def current_user
    @current_user ||= Client.find_by( id: session[ :id ] )
  end

  def authenticate_jwt
    begin
      token = request.authorization.split.last
      payload = JWT.decode( token, ENV[ 'RAILS_MASTER_KEY' ], true, { algorithm: 'HS256' } )[ 0 ]
      @current_user = Client.find_by( id: JSON.parse( payload )[ "id" ] )
    rescue
      render json: { errors: [ "Unauthorized" ] }, status: 401
    end
  end

  def authorize
    unless current_user.present?
      render json: { errors: [ "Login required to view that page", "Don't have an account? Contact a hypnotist for credentials" ] }, status: 401
    end
  end

  def about
    render json: { messages: [ "my-sms-messenger v0.0.1 - ©#{ Date.today.year } Josh Frank" ] }, status: 200
  end

end
