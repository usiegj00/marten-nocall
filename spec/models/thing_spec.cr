require "./spec_helper"

describe Thing do
  describe "#Thing" do
    it "Validates" do
      thing = Thing.new()
      thing.save!
    end
  end
end

