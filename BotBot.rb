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
    @socket = TCPSocket.open(server, port)
  end

  def say(str)
    @socket.puts(str + "\n")
  end

  def run
    puts "Initiating handshake with server..."
    say "USER #{nick} 0 * #{nick}"
    say "NICK #{nick}"
    say "JOIN #bbtest"

    puts "Successfully connected, now listening in channel"

    until @socket.eof? do
      msg = @socket.gets
      puts "SERVER <<< #{msg}"
    end
  end

end

bot = Bot.new("hirugabotto", "irc.rizon.net", 6667, "derf")
bot.run()