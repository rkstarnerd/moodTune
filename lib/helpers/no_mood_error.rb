class NoMoodError < StandardError
  def message
    "No mood or tone was found for this input."
  end
end