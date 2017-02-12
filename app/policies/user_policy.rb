class UserPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def update?
    user.admin? || user == record
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope < Scope
    def resolve
      user.admin? ? scope.all : scope.where(:id => user.id)
    end
  end
end
