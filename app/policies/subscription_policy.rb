class SubscriptionPolicy < ApplicationPolicy
  def edit?
    record.user == user
  end

  def update?
    edit?
  end
end
