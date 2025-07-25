require 'rails/mongoid'

class Message

  include Mongoid::Document
  include Mongoid::Timestamps
  field :to, type: String
  field :content, type: String
  field :session_id, type: String

  before_validation :parse_phone_with_phonelib
  validate :valid_us_phone

  private

  def parse_phone_with_phonelib
    self.to = Phonelib.parse( self.to, 'US' ).international
  end

  def valid_us_phone
    if self.to.present? && Phonelib.invalid_for_country?( self.to, 'US' )
      errors.add( :phone, "must be a valid US phone number" )
    end
  end

end
