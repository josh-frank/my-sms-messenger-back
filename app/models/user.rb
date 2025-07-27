class User

  include ActiveModel::SecurePassword
  has_secure_password

  include Mongoid::Document
  include Mongoid::Timestamps
  field :phone, type: String
  field :password_digest, type: String

end
