class User < ApplicationRecord
  before_validation :default_values
  validates :admin, inclusion: {in: [true, false]}
  validates :name, presence: true
  devise :database_authenticatable, :lockable, :omniauthable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         omniauth_providers: [:facebook]

  delegate :active?, :cancelling?, :cancel_subscription, :inactive?, :reactivate, :source,
           :subscription, to: :customer_facade

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
    end
  end

  def create_subscription(stripe_token)
    customer_facade.update(source: stripe_token)
    customer_facade.create_subscription
  end
  
  def update_subscription(params)
    customer_facade.update(source: params[:stripe_token]) if params[:stripe_token]
  end

  def customer_facade
    @customer_facade ||= StripeService::CustomerFacade.find_or_create(self)
  end

  def reload
    super
    @customer_facade = nil
  end

  private

  def default_values
    self.admin = false if admin.nil?
  end
end
