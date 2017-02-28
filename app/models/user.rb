class User < ApplicationRecord
  has_many :payment_methods
  has_one :subscription

  before_validation :default_values
  validates :admin, inclusion: { in: [true, false] }
  validates :name, presence: true
  devise :database_authenticatable, :lockable, :omniauthable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         omniauth_providers: [:facebook, :google_oauth2]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name
      # user.image = auth.info.image
    end
  end

  def active?
    false
  end

  private

  def default_values
    self.admin = false if self.admin.nil?
  end
end
