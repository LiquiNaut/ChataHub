module Users
  class InvitationsController < Devise::InvitationsController
    prepend_before_action :reject_signed_in_invitee, only: %i[edit update]
    before_action :authorize_invitation, only: %i[new create]

    private

    # Clearer than Devise "already signed in"
    def reject_signed_in_invitee
      return unless user_signed_in?

      redirect_to root_path, alert: "Si prihlásený ako #{current_user.email}. Na prijatie pozvánky sa odhlás a otvor odkaz znova."
    end

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
