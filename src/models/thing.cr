class Thing < Marten::Model
  field :id, :big_int, primary_key: true, auto: true
  field :must_have, :uuid

  before_validation :ensure_must_have
  def ensure_must_have
    raise "There should not already be a validation error at this point." if self.errors.any?
    self.must_have = UUID.random
  end
  
end

