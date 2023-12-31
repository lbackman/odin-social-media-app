class UsersController < ApplicationController
  def index
    @users = User
              .search(params[:search])
              .includes(:user_information, avatar_attachment: :blob)
              .order(:created_at)
              .page(params[:page])

    @users.each do |user|
      friend_request = FriendRequest.mutual(user, current_user)
      mark_friend_request_notifications_as_read(friend_request) if friend_request
    end
  end

  def show
    @user = User.find_by_id(params[:id])
    @friend_amount = User.friends(@user).size
    @friend_request = FriendRequest.mutual(current_user, @user) || FriendRequest.new
    if current_user == @user || current_user.friends_with?(@user)
      @posts = Post.where(author: @user).with_author_information.order(created_at: :desc).page(params[:page])
    else
      @posts = Post.where(author: nil).page(params[:page])
    end

    mark_friend_request_notifications_as_read(@friend_request)
  end

  def friends
    @user = User.find_by_id(params[:id])
    @friends = User
                .friends(@user)
                .search(params[:search])
                .includes(:user_information, avatar_attachment: :blob)
                .page(params[:page])
  end

  def purge_avatar
    @user = User.find_by_id(params[:id])
    @user.avatar.purge
    redirect_back(fallback_location: user_path(@user), notice: "Avatar removed")
  end

  private

    def mark_friend_request_notifications_as_read(friend_request)
      if friend_request.receiver == current_user
        mark_notifications_as_read(
          friend_request.notifications_as_friend_request.where(recipient: current_user)
        )
      end
    end
end
