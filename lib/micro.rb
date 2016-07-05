module Micro
  extend self

  def const_missing const
    model = MicroClient.get_model(const, self)
    super(const) if model.nil?
    model
  end
end
