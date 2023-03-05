class Thing < Marten::Model
  field :id, :big_int, primary_key: true, auto: true
  field :must_have, :uuid

  before_validation :ensure_must_have
  def ensure_must_have
    self.must_have = UUID.random
  end
  
end

