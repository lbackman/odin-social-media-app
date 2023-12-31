class Comment < ApplicationRecord
  include Models::Likeable
  include ActionView::RecordIdentifier

  belongs_to :author, class_name: 'User'
  belongs_to :commentable, polymorphic: true, optional: true, counter_cache: true

  validates :body, presence: true

  after_create_commit -> {
    broadcast_append_later_to [commentable, :comments],
                              target: "#{dom_id(commentable, :comments)}",
                              partial: "comments/comment",
                              locals: { comment: self, commentable:, user: Current.user }
    broadcast_append_later_to [author&.to_gid_param],
                              target: "controls_comment_#{id}",
                              partial: "comments/user_controls",
                              locals: { comment: self, author: author }
  }

  after_update_commit -> {
    broadcast_replace_later_to self, locals: { comment: self, commentable:, user: Current.user }
    broadcast_append_later_to [author&.to_gid_param],
                              target: "controls_comment_#{id}",
                              partial: "comments/user_controls",
                              locals: { comment: self, author: author }
  }

  after_destroy_commit -> {
    broadcast_remove_to self
  }
end
