require "./spec_helper"

describe Auth::SignInHandler do
  describe "#get" do
    it "redirects to the profile page if the user is already authenticated" do
      user = create_user(email: "test@example.com", password: "insecure")

      url = Marten.routes.reverse("auth:sign_in")

      Marten::Spec.client.sign_in(user)
      response = Marten::Spec.client.get(url)

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("auth:profile")
    end

    it "renders the form as expected for anonymous users" do
      url = Marten.routes.reverse("auth:sign_in")
      response = Marten::Spec.client.get(url)

      response.status.should eq 200
      response.content.includes?("Sign in").should be_true
    end
  end

  describe "#post" do
    it "renders the form if the form data is invalid" do
      url = Marten.routes.reverse("auth:sign_in")
      response = Marten::Spec.client.post(url, data: {"email": "", "password": ""})

      response.status.should eq 200
      response.content.includes?("Sign in").should be_true
      Marten::Spec.client.get(Marten.routes.reverse("auth:profile")).status.should eq 302
    end

    it "renders the form if the specified credentials are invalid" do
      user = create_user(email: "test@example.com", password: "insecure")

      url = Marten.routes.reverse("auth:sign_in")
      response = Marten::Spec.client.post(url, data: {"email": user.email, "password": "bad"})

      response.status.should eq 200
      response.content.includes?("Sign in").should be_true
      response.content.includes?(
        "Please enter a correct email address and password. Note that both fields may be case-sensitive."
      ).should be_true
      Marten::Spec.client.get(Marten.routes.reverse("auth:profile")).status.should eq 302
    end

    it "renders the form if the specified email does not match an existing user" do
      user = create_user(email: "test@example.com", password: "insecure")

      url = Marten.routes.reverse("auth:sign_in")
      response = Marten::Spec.client.post(url, data: {"email": user.email, "password": "bad"})

      response.status.should eq 200
      response.content.includes?("Sign in").should be_true
      response.content.includes?(
        "Please enter a correct email address and password. Note that both fields may be case-sensitive."
      ).should be_true
      Marten::Spec.client.get(Marten.routes.reverse("auth:profile")).status.should eq 302
    end

    it "authenticates the user as expected if the credentials are valid" do
      user = create_user(email: "test@example.com", password: "insecure")

      url = Marten.routes.reverse("auth:sign_in")
      response = Marten::Spec.client.post(url, data: {"email": user.email, "password": "insecure"})

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("auth:profile")
      Marten::Spec.client.get(Marten.routes.reverse("auth:profile")).status.should eq 200
    end
  end
end
