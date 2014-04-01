# == Schema Information
#
# Table name: bots
#
#  id            :integer          not null, primary key
#  nickname      :string(255)
#  password_hash :string(255)
#  server        :string(255)
#  port          :integer
#  created_at    :datetime
#  updated_at    :datetime
#

require 'socket'

class Bot < ActiveRecord::Base

  validates :nickname, presence: true

  attr_reader :password

  #connect to and identify with server
  def run
    Thread.new do
      puts "INFO>> Spinning up new thread..."
      puts "INFO>> Opening socket with #{self.server} on port #{self.port}"
      @socket = TCPSocket.open(self.server, self.port)
      puts "INFO>> Handshaking with #{self.nickname}"
      rawc("USER #{self.nickname} 0 * #{self.nickname}")
      rawc("NICK #{self.nickname}")
      puts "INFO>> Joining #bbtest..."
      rawc("JOIN #bbtest")
      puts "INFO>> Listening to socket..."

      until @socket.eof? do
        msg = @socket.gets
        puts "SERVER << " + msg
      end
    end
  end

  def password=(plaintext_password)
    @password = plaintext_password
    self.password_hash = BCrypt::Password.create(plaintext_password)
  end

  #write a raw command string to the socket
  def rawc(str)
    @socket.puts str + "\n"
  end

end
