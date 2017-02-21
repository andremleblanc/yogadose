class PaymentMethod < ApplicationRecord
  belongs_to :user
  validates :stripe_token, presence: true

  def brand
    card.brand
  end

  def card
    @card ||= stripe_token_object.card
  end

  def last_four
    card.last4
  end

  private

  # TODO: Refactor into seperate object or better name
  def stripe_token_object
    Stripe::Token.retrieve(id: stripe_token)
  end
end
