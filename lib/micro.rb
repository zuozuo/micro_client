module Micro
  extend self

  def safe_const_get(const)
    const_defined?(const) ? const_get(const) : nil
  end

  def const_missing const
    model = MicroClient.get_model(const, self)
    super(const) if model.nil?
    model
  end
end
