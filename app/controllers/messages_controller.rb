class MessagesController < ApplicationController

  def create
    @new_message = Message.new( message_params )
    unless message_params[ :to ].present? && @new_message.save
      render json: @new_message.errors.full_messages, status: 400
    else
      @send_message = MessagesHelper.send( message_params[ :to ], message_params[ :content ] )
      render json: @new_message, status: 200
    end
  end

  def show
    @messages = Message.where( session_id: params[ :session_id ] ).order( created_at: :desc )
    render json: @messages, status: 200
  end

  private

  def message_params
    params.require( :message ).permit( :to, :content, :session_id )
  end

end
