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

  # def default_source
  #   stripe_customer ? stripe_customer.default_source : nil
  # end

  def update_stripe(args)
    args.each { |k,v| stripe_customer.send("#{k}=", v) }
    stripe_customer.save
  end

  private

  def default_values
    self.admin = false if self.admin.nil?
  end

  def link_to_stripe
    stripe_customer = Stripe::Customer.create({ email: email })
    self.stripe_id = stripe_customer.id
    self.save!
    stripe_customer
  end

  def stripe_customer
    @stripe_customer ||= begin
      stripe_id ? Stripe::Customer.retrieve(stripe_id) : link_to_stripe
    end
  end
end
