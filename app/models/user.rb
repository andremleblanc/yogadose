class User < ApplicationRecord
  devise :database_authenticatable, :lockable, :omniauthable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         omniauth_providers: [:facebook, :google]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name
      user.image = auth.info.image
    end
  end
end