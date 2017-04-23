module StripeService
  class SubscriptionFacade
    attr_reader :customer
    delegate :id, :status, to: :subscription

    def initialize(customer, subscription = nil)
      @customer = customer
      @subscription = subscription
    end

    def active?
      !inactive?
    end

    def cancel_subscription
      subscription.delete(at_period_end: true)
    end

    def cancelling?
      return true if subscription.canceled_at.present?
      false
    end

    def inactive?
      return true if subscription.blank?
      false
    end

    def next_charge
      @next_charge ||= active? && !cancelling? ? next_charge_time : nil
    end

    def reactivate
      if cancelling?
        subscription.plan = subscription.plan.id
        subscription.save
      end
    end

    def subscription
      @subscription ||= customer.subscriptions.first
    end

    private

    def next_charge_time
      Time.at(subscription.current_period_end).advance(days: 1).beginning_of_day
    end
  end
end