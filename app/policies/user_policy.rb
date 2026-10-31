class UserPolicy < ApplicationPolicy
  # Never your own, keeps the last admin
  def update_role?
    user.admin? && record != user
  end
end
