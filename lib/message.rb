class Message

  MSG_TYPES = [
    :notice,
    :mode,
    :servmsg,
    :privmsg,
    :ping,
    :error,
    :other
  ]

  def initialize(str, verbose = false)
    @parts = str.split(" ")
    p @parts
  end

end