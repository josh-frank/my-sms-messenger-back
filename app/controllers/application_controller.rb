class ApplicationController < ActionController::API

  def about
    render json: { messages: [ "my-sms-messenger v0.0.1 - ©#{ Date.today.year } Josh Frank" ] }, status: 200
  end

end
