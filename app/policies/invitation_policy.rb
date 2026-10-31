# Headless, record is :invitation
class InvitationPolicy < ApplicationPolicy
  def create?
    user.owner? || user.admin?
  end

  def assignable_roles
    if user.admin? then User.roles.keys
    elsif user.owner? then %w[member]
    else []
    end
  end
end
