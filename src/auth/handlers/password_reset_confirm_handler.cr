require "./concerns/*"

module Auth
  class PasswordResetConfirmHandler < Marten::Handlers::Schema
    include RequireAnonymousUser

    @user : User?

    schema PasswordResetConfirmSchema
    template_name "auth/password_reset_confirm.html"
    success_route_name "auth:sign_in"

    before_dispatch :process_password_reset_token

    def process_valid_schema
      session.delete(TOKEN_SESSION_KEY)

      @user.not_nil!.set_password(schema.validated_data["password1"].as(String))
      @user.not_nil!.save!

      flash[:notice] = "Password updated successfully."

      super
    end

    private SET_PASSWORD_TOKEN = "set-password"
    private TOKEN_SESSION_KEY  = "_password_reset_token"

    private def get_user
      User.get(pk: Base64.decode_string(params["uid"].to_s))
    rescue Base64::Error
      nil
    end

    private def process_password_reset_token
      @user = get_user

      if !(user = @user).nil?
        token = params["token"].to_s
        if token == SET_PASSWORD_TOKEN
          session_token = session[TOKEN_SESSION_KEY]?.to_s
          return if MartenAuth.valid_password_reset_token?(user, session_token)
        elsif MartenAuth.valid_password_reset_token?(user, token)
          # In order to prevent risks around leaking the password reset token in the HTTP Referer header, we store the
          # actual token in the session and we redirect to a URL that does not contain it.
          session[TOKEN_SESSION_KEY] = token
          return redirect reverse("auth:password_reset_confirm", uid: params["uid"].to_s, token: SET_PASSWORD_TOKEN)
        end
      end

      flash[:notice] = "This password reset link is no longer valid."
      redirect reverse("auth:sign_in")
    end
  end
end
