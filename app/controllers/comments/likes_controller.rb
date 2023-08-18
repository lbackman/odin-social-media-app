class Comments::LikesController < ApplicationController
  include Likeable
  before_action :set_likeable

  private

    def set_likeable
      @likeable = Comment.find(params[:comment_id])
    end
end
