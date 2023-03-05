require "./spec_helper"

describe Auth::PasswordResetInitiateHandler do
  describe "#get" do
    it "redirects to the profile page if the user is already authenticated" do
      user = create_user(email: "test@example.com", password: "insecure")

      url = Marten.routes.reverse("auth:password_reset_initiate")

      Marten::Spec.client.sign_in(user)
      response = Marten::Spec.client.get(url)

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("auth:profile")
    end

    it "renders the form as expected for anonymous users" do
      url = Marten.routes.reverse("auth:password_reset_initiate")
      response = Marten::Spec.client.get(url)

      response.status.should eq 200
      response.content.includes?("Reset password").should be_true
    end
  end

  describe "#post" do
    it "renders the form if the form data is invalid" do
      url = Marten.routes.reverse("auth:password_reset_initiate")
      response = Marten::Spec.client.post(url, data: {"email": ""})

      response.status.should eq 200
      response.content.includes?("Reset password").should be_true
    end

    it "sends a password reset email and redirects to the sign in page if the form data is valid" do
      user = create_user(email: "test@example.com", password: "insecure")

      url = Marten.routes.reverse("auth:password_reset_initiate")
      response = Marten::Spec.client.post(url, data: {"email" => user.email})

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("auth:sign_in")

      Marten::Spec.delivered_emails.size.should eq 1
      Marten::Spec.delivered_emails[0].should be_a Auth::PasswordResetEmail
      Marten::Spec.delivered_emails[0].to[0].address.should eq user.email
    end

    it "does not send a password reset email and redirects to the sign in page if no user matches the provided email" do
      url = Marten.routes.reverse("auth:password_reset_initiate")
      response = Marten::Spec.client.post(url, data: {"email" => "unknown@example.com"})

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("auth:sign_in")

      Marten::Spec.delivered_emails.should be_empty
    end
  end
end
