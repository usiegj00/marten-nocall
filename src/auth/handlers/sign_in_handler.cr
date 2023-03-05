module Auth
  class SignInHandler < Marten::Handlers::Schema
    include RequireAnonymousUser

    schema SignInSchema
    template_name "auth/sign_in.html"
    success_route_name "auth:profile"

    def process_valid_schema
      MartenAuth.sign_in(request, schema.as(SignInSchema).user.not_nil!)
      redirect(success_url)
    end
  end
end
