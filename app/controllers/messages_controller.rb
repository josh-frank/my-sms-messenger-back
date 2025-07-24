class MessagesController < ApplicationController

  def create
    @new_message = Message.new( message_params )
    @send_message = MessagesHelper.send( message_params[ :to ], message_params[ :content ] )
    if @new_message.save && !@send_message.error
      render json: @new_message, status: 200
    else
      render json: @new_message.errors.full_messages, status: 400
    ende
  end

  private

  def message_params
    params.require( :message ).permit( :to, :content, :session_id )
  end

end
