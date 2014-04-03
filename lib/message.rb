class Message

  attr_reader :parts, :str

  MSG_TYPES = [
    :notice,
    :mode,
    :servmsg,
    :privmsg,
    :ping,
    :error,
    :other
  ]

  def initialize(str)
    @str = str
    @parts = str.split(" ")
  end

  #return a human-readable-message
  def stringify
    self.str
  end

end