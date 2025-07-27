class SessionsController < ApplicationController

  before_action :parse_and_validate_phone_number, only: [ :send_new_user_code, :check_new_user_code ]
  before_action :set_current_user, only: [ :user_code, :login ]

  skip_before_action :authorize
  skip_before_action :authenticate_jwt

  def send_new_user_code
      begin
          verification = MessagesHelper.send_verification_code( @parse_phone )
          render json: { verification_sid: verification.sid }, status: 200
      rescue Twilio::REST::RestError => error
    #   rescue error
          render json: { errors: [ error.error_message ] }, status: error.code
      end
  end

  def check_new_user_code
      begin
          check_code = MessagesHelper.check_verification_code( @parse_phone, session_params[ :code ] )
          unless check_code.valid
              render json: { errors: [ "Invalid verification code", "Enter digits only: no spaces or other characters" ] }, status: 401
          else
              render json: { verification_sid: check_code.sid }, status: 200
          end
      rescue Twilio::REST::RestError => error
    #   rescue error
          render json: { errors: [ error.error_message ] }, status: error.code
      end
  end

  def user_code
      begin
          verification = current_user.send_code
          render json: { user_id: current_user.id, verification_sid: verification.sid }, status: 200
      rescue Twilio::REST::RestError => error
    #   rescue error
          render json: { errors: [ error.error_message ] }, status: error.code
      end
  end
  
  def login
      begin
          check_code = current_user.check_code( session_params[ :code ] )
          unless check_code.valid
              render json: { errors: [ "Invalid verification code", "Enter digits only: no spaces or other characters" ] }, status: 401
          else
              token = JWT.encode( current_user.to_json(), ENV[ 'RAILS_MASTER_KEY' ], 'HS256' )
              session[ :id ] = current_user.id
              session[ :token ] = token
              render json: { user: current_user, verification_sid: check_code.sid, token: token }, status: 200
          end
      rescue Twilio::REST::RestError => error
    #   rescue error
          render json: { errors: [ error.error_message ] }, status: error.status_code
      end
  end

  def logout
      @current_user = nil
      session[ :id ] = nil
      session[ :user_type ] = nil
      session[ :token ] = nil
      render json: { messages: [ "Logged out successfully" ] }, status: 200
  end

  private

  def session_params
      params.require( :session ).permit( :password, :phone, :code )
  end

  def set_current_user
      @current_user = User.find_by( phone: Phonelib.parse( session_params[ :phone ], "US" ).international )
      render json: { errors: [ "Invalid phone number or password" ] }, status: 401 unless @current_user && @current_user.authenticate( session_params[ :password ] )
  end

  def parse_and_validate_phone_number
      @parse_phone = Phonelib.parse( session_params[ :phone ], 'US' ).international
      render json: { errors: [ 'Phone must be a valid US phone number' ] }, status: 401 unless Phonelib.valid_for_country?( session_params[ :phone ], 'US' ) 
      render json: { errors: [ "Phone number already taken" ] }, status: 401 if User.exists?( phone: @parse_phone )
  end

end
