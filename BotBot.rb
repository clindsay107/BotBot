#!/usr/bin/env ruby

require 'socket'

class Bot
  attr_reader :nick, :server, :port, :chan
  attr_accessor :socket

  def initialize(nick, server, port, chan)
    @nick = nick
    @server = server
    @port = port
    @chan = chan
  end

  def say(str)
    @socket.puts(str + "\n")
  end

  def run
    @socket = TCPSocket.open(self.server, self.port)
    puts "Initiating handshake with server..."
    say "USER #{nick} 0 * #{nick}"
    say "NICK #{nick}"

    until @socket.eof? do
      #msg = Message.new(@socket.gets)
      msg = @socket.gets
      if msg.include?(' 376 ')
        say "JOIN #bbtest"
      end
      puts "SERVER <<< #{msg}"
    end
  end

end

bot = Bot.new("hirugabotto", "irc.rizon.net", 6667, "derf")
bot.run()