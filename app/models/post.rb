class Post < ApplicationRecord
  paginates_per 10
  include Models::Likeable

  belongs_to :author, class_name: 'User'
  has_many :comments, as: :commentable, dependent: :destroy
  
  validates :body, presence: true

  scope :with_author_information, -> do
    includes(
      comments: [author: [:user_information, avatar_attachment: :blob]],
      author: [:user_information, avatar_attachment: :blob]
    )
  end

  scope :of_friends_and_user, ->(user) do
    where("author_id IN (?) OR author_id = ?", User.friends(user).pluck(:id), user.id)
  end
end
