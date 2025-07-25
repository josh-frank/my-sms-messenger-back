class ApplicationController < ActionController::API

  def about
    render json: { messages: [ "Hypnosis API v#{ ENV[ 'APP_VERSION' ] } - ©#{ Date.today.year } Hypnotic Power LLC" ] }, status: 200
  end

end
