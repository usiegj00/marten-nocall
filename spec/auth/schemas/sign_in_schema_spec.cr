require "./spec_helper"

describe Auth::SignInSchema do
  describe "#valid?" do
    it "returns true if the email and password are provided and the authentication is successful" do
      user = create_user(email: "test@example.com", password: "insecure")

      schema = Auth::SignInSchema.new(
        Marten::HTTP::Params::Data{"email" => ["test@example.com"], "password" => ["insecure"]}
      )
      schema.valid?.should be_true
      schema.errors.should be_empty
    end

    it "returns false if the email address and password are not provided" do
      schema = Auth::SignInSchema.new(
        Marten::HTTP::Params::Data{"email" => [""], "password" => [""]}
      )

      schema.valid?.should be_false

      schema.errors.size.should eq 2
      schema.errors[0].field.should eq "email"
      schema.errors[0].type.should eq "required"
      schema.errors[1].field.should eq "password"
      schema.errors[1].type.should eq "required"
    end

    it "returns false if the email matches an existing user but the password is invalid" do
      user = create_user(email: "test@example.com", password: "insecure")

      schema = Auth::SignInSchema.new(
        Marten::HTTP::Params::Data{"email" => ["test@example.com"], "password" => ["bad"]}
      )

      schema.valid?.should be_false

      schema.errors.size.should eq 1
      schema.errors[0].field.should be_nil
      schema.errors[0].message.should eq(
        "Please enter a correct email address and password. Note that both fields may be case-sensitive."
      )
    end

    it "returns false if the email does not match an existing user" do
      schema = Auth::SignInSchema.new(
        Marten::HTTP::Params::Data{"email" => ["unknown@example.com"], "password" => ["insecure"]}
      )

      schema.valid?.should be_false

      schema.errors.size.should eq 1
      schema.errors[0].field.should be_nil
      schema.errors[0].message.should eq(
        "Please enter a correct email address and password. Note that both fields may be case-sensitive."
      )
    end
  end
end
