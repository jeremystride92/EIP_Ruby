module Environment
  def pin_required?
    ENV['require_pin'] == "required"
  end
end