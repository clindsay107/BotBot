# General messages received from the server over our TCPSocket
class Message

  attr_reader :parts, :str, :type

  def initialize(str)
    @str = str
    @parts = str.split(" ")
    @type = @parts[1]
  end

  # Return a human-readable-message
  def stringify
    self.str
  end

end

# This is for channel/query messages sent from another user
class PrivateMessage < Message

  attr_reader :parts, :type, :user_string, :chan, :text, :nickname, :hostname

  def initialize(str)
    @str = str
    @parts = str.split(" ")
    @type = "PRIVMSG"
    parse()
  end

  # Break up the message into intelligible parts we can use and store vars
  def parse
    @user_string = self.parts[0][1..-1]
    parse_user_string()
    @chan = self.parts[2][1..-1]
    @text = self.parts[3..-1].join(" ")[1..-1]
  end

  def parse_user_string
    @nickname = /(^.+)\!/.match(self.user_string)[1]
    @hostname = /@(.*$)/.match(self.user_string)[1]
  end

  def stringify
    self.text
  end

end
