module StripeService
  class CustomerFacade
    STANDARD_PLAN = 'standard'.freeze

    attr_reader :customer
    delegate :email, :id, to: :customer
    delegate :active?, :cancelling?, :reactivate, :cancel_subscription, :inactive?, to: :subscription

    def initialize(customer)
      @customer = customer
    end

    def create_subscription(plan = STANDARD_PLAN)
      raise StandardError unless inactive?
      Stripe::Subscription.create(customer: id, plan: plan)
      fresh_customer!
      @subscription = SubscriptionFacade.new(customer)
    end

    def source
      customer.sources.data.last
    end

    def subscription
      @subscription ||= SubscriptionFacade.new(customer)
    end

    def update(args)
      args.each { |k, v| customer.send("#{k}=", v) }
      customer.save
    end

    private

    def fresh_customer!
      @customer = Stripe::Customer.retrieve(customer.id)
    end

    class << self
      def create(user, params = {})
        customer = Stripe::Customer.create({email: user.email}.merge(params))
        user.stripe_id = customer.id
        user.save!
        new(customer)
      end

      # TODO: Cache this
      def find(id)
        new(Stripe::Customer.retrieve(id))
      end

      def find_or_create(user)
        user.stripe_id ? find(user.stripe_id) : create(user)
      end
    end
  end
end