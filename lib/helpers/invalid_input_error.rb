class InvalidInputError < TypeError
  def message
    "The input was invalid."
  end
end