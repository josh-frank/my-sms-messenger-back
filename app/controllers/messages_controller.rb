class MessagesController < ApplicationController

  def create
    render json: { test: 'Test' }, status: :ok
  end

  private

  def message_params
    params.require( :message ).permit( :to, :content, :session_id )
  end


end
