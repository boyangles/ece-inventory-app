class RequestItemCommentsController < ApplicationController
  before_action :set_comment, :only => []
  def create

    @request_item = RequestItem.find(params[:request_item_id])
    @request_item_comment = RequestItemComment.new(request_item_comment_params)
    @request_item_comment.user_id = current_user.id
    @request_item_comment.request_item_id = params[:request_item_id]

    if @request_item_comment.save
      respond_to do |format|
        format.html {redirect_to request_path(RequestItem.find(params[:request_item_id]).request)}
        format.js
      end
    else
      flash.now[:danger] = "Comment could not be saved"
      redirect_to request_path(RequestItem.find(params[:request_item_id]).request)
    end
  end

  private
  def set_comment
    @comment = Comment.find(params[:id])
  end

  def request_item_comment_params
    # Rails 4+ requires you to whitelist attributes in the controller.
    params.fetch(:request_item_comment, {}).permit(:comment)
  end
end
