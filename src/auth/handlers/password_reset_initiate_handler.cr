require "./concerns/*"

module Auth
  class PasswordResetInitiateHandler < Marten::Handlers::Schema
    include RequireAnonymousUser

    schema PasswordResetInitiateSchema
    template_name "auth/password_reset_initiate.html"
    success_route_name "auth:sign_in"

    def process_valid_schema
      flash[:notice] = "We've sent you a recovery e-mail! " +
                       "You will receive instructions by e-mail to reset your password."

      if (user = User.get_by_natural_key(self.schema.validated_data["email"].to_s))
        PasswordResetEmail.new(user, request).deliver
      end

      redirect(success_url)
    end
  end
end
