require 'rails/mongoid'

class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  field :to, type: String
  field :content, type: String
  field :session_id, type: String
end
