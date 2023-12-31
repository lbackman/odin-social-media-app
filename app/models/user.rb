class User < ApplicationRecord
  paginates_per 10
  has_one_attached :avatar
  after_create :send_welcome_email
  validates :avatar,
            content_type: ['image/png', 'image/jpeg'],
            dimension: { width: { in: 80..250 }, height: { in: 80..250 } },
            aspect_ratio: :square
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :trackable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[facebook]

  # Friendships as sender
  has_many :sent_friend_requests,
           class_name: "FriendRequest",
           foreign_key: :sender_id,
           dependent: :destroy

  # Friendships as receiver
  has_many :received_friend_requests,
           class_name: "FriendRequest",
           foreign_key: :receiver_id,
           dependent: :destroy    

  scope :friends, ->(user) do
    User.where(
      id: [
        *FriendRequest.where(sender: user, accepted: true).pluck(:receiver_id),
        *FriendRequest.where(receiver: user, accepted: true).pluck(:sender_id)
      ]
    )
  end

  def friends_with?(other_user)
    FriendRequest.exists?(
      sender_id:   [self.id, other_user.id],
      receiver_id: [other_user.id, self.id],
      accepted:    true
    )
  end

  def sent_friend_request_to?(other_user)
    FriendRequest.exists?(
      sender_id:   self.id,
      receiver_id: other_user.id,
      accepted:    false
    )
  end

  def received_friend_request_from?(other_user)
    FriendRequest.exists?(
      sender_id:   other_user.id,
      receiver_id: self.id,
      accepted:    false
    )
  end

  def friend_status(other_user)
    FriendRequest.find_by(sender: [self, other_user], receiver: [self, other_user])
  end

  # User information
  has_one :user_information, dependent: :destroy, autosave: true
  accepts_nested_attributes_for :user_information
  delegate :first_name,
           :last_name,
           :date_of_birth,
           :hometown,
           :about_me, to: :user_information, allow_nil: true

  def full_name
    "#{first_name} #{last_name}"
  end

  # Posts
  has_many :posts, foreign_key: :author_id, dependent: :destroy

  # Notifications
  has_many :notifications, as: :recipient, dependent: :destroy

  # Likes
  has_many :likes, dependent: :destroy

  # Comments
  has_many :comments, foreign_key: :author_id, dependent: :nullify

  # OmniAuth
  def self.from_omniauth(auth)
    user = User.find_by(email: auth.info.email)
    unless user
      user = User.create!(provider: auth.provider, uid: auth.uid, email: auth.info.email, password: Devise.friendly_token[0, 20])
      user.create_user_information!(first_name: auth.info.first_name, last_name: auth.info.last_name)
    end
    user
  end

  private

    def self.search(search_term)
      if search_term && search_term != ''
        searches = []
        terms = search_term.downcase.split
        terms.each do |term|
          searches <<
          User
            .joins(:user_information)
            .where(
              "lower(user_informations.first_name) LIKE ? OR lower(user_informations.last_name) LIKE ?",
              "%#{term}%",
              "%#{term}%")
        end
        searches.reduce(:and)
      else
        all
      end
    end

    def send_welcome_email
      UserMailer.welcome_email(self).deliver_later
    end
end
