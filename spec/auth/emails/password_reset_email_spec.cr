require "./spec_helper"

describe Auth::PasswordResetEmail do
  describe "#html_body" do
    it "can be rendered" do
      user = create_user(email: "test@example.com", password: "insecure")
      user_uid = Base64.urlsafe_encode(user.pk.to_s)

      request = Marten::HTTP::Request.new(
        method: "GET",
        resource: "/test/xyz",
        headers: HTTP::Headers{"Host" => "127.0.0.1"},
      )

      email = Auth::PasswordResetEmail.new(user, request)

      email.html_body.should_not be_nil
    end
  end

  describe "#subject" do
    it "returns the expected subject" do
      user = create_user(email: "test@example.com", password: "insecure")
      request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz")

      email = Auth::PasswordResetEmail.new(user, request)

      email.subject.should eq "Reset your password"
    end
  end

  describe "#to" do
    it "returns the user email address" do
      user = create_user(email: "test@example.com", password: "insecure")
      request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz")

      email = Auth::PasswordResetEmail.new(user, request)

      email.to.size.should eq 1
      email.to.first.address.should eq user.email
    end
  end
end
