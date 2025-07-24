require 'rubygems'
require 'dotenv-rails'
require 'twilio-ruby'

module TwilioModule

  @twilio_client = Twilio::REST::Client.new( ENV[ 'TWILIO_ACCOUNT_SID' ], ENV[ 'TWILIO_AUTH_TOKEN' ] )
  @twilio_service = @twilio_client.verify.v2.services( ENV[ 'TWILIO_VERIFY_SID' ] )
  @twilio_phone_number = ENV[ 'TWILIO_PHONE_NUMBER' ]
  @twilio_logger = Logger.new( "#{ Rails.root }/log/twilio.log" )

  def self.client
    @twilio_client
  end

  def self.service
    @twilio_service
  end

  def self.log( message )
    @twilio_logger.debug( message )
  end

  def self.send( recipient_phone_number, content )
    begin
      message = @twilio_client.api.account.messages.create(
        from: @twilio_phone_number,
        to: recipient_phone_number, 
        body: content
      )
    rescue Twilio::REST::TwilioError => error
      @twilio_logger.error( error )
      error
    end
  end

  def self.send_verification_code( recipient_phone_number )
    begin
      verification = @twilio_service.verifications.create(
        to: recipient_phone_number,
        channel: 'sms'
      )
    rescue Twilio::REST::TwilioError => error
      @twilio_logger.error( error )
      error
    end
  end

  def self.check_verification_code( recipient_phone_number, code )
    begin
      verification_check = @twilio_service.verification_checks.create(
        to: recipient_phone_number,
        code: code
      )
    rescue Twilio::REST::TwilioError => error
      @twilio_logger.error( error )
      error
    end
  end

end
