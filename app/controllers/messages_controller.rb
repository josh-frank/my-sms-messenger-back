class MessagesController < ApplicationController

  before_action :set_messages_by_session_id, only: [ :create, :show ]
  skip_before_action :authorize
  skip_before_action :authenticate_jwt

  def create
    @new_message = Message.new( message_params )
    unless message_params[ :to ].present? && @new_message.save
      render json: @new_message.errors.full_messages, status: 400
    else
      @send_message = MessagesHelper.send( message_params[ :to ], message_params[ :content ] )
      render json: @messages_by_session_id, status: 200
    end
  end

  def show
    render json: @messages_by_session_id, status: 200
  end

  private

  def set_messages_by_session_id
    @messages_by_session_id = Message.by_session_id( params[ :session_id ] )
  end

  def message_params
    params.require( :message ).permit( :to, :content, :session_id )
  end

end
