module Users
  class InvitationsController < Devise::InvitationsController
    before_action :authorize_invitation, only: %i[new create]

    private

    def authorize_invitation
      authorize :invitation, :create?
      return unless action_name == "create"

      role = invite_params[:role] || "member"
      raise Pundit::NotAuthorizedError unless policy(:invitation).assignable_roles.include?(role)
    end

    def invite_params
      super.compact_blank
    end
  end
end
