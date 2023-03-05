ENV["MARTEN_ENV"] = "test"

require "spec"

require "../src/project"
require "marten/spec"
require "marten_auth/spec"

def create_user(email : String, password : String)
  user = Auth::User.new(email: email)
  user.set_password(password)
  user.save!

  user
end
