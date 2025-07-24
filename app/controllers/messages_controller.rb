class MessagesController < ApplicationController

  def create
    render json: { test: 'Test' }, status: :ok
  end

end
