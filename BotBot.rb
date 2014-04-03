#!/usr/bin/env ruby

require 'socket'
require './lib/message'
require './lib/texttrigger'

class Bot
  attr_reader :nick, :server, :port, :chan, :verbose
  attr_accessor :socket

  def initialize(nick, server, port, chan, verbose = false)
    @nick = nick
    @server = server
    @port = port
    @chan = chan
    @verbose = verbose
  end

  def say(str)
    @socket.puts(str + "\n")
  end

  def say_to_user(user, str)
    say("PRIVMSG #{user} :#{str}")
  end

  #Open a TCPSocket and connect, joining the channel when appropriate.
  #Turn on verbose logging if declared in init (helpful for debugging)
  def run
    @socket = TCPSocket.open(self.server, self.port)
    puts "Initiating handshake with server..."
    say "USER #{nick} 0 * #{nick}"
    say "NICK #{nick}"

    until @socket.eof? do
      msg = @socket.gets
      msg = (msg.split(" ")[1] == "PRIVMSG" ? PrivateMessage.new(msg) : Message.new(msg))

      #keep alive
      if msg.parts[0] == "PING"
        say "PONG :pingis"
      else
        case msg.parts[1]
        when "001"
          puts "[INFO]>> Processing connection to server..."
        when "376"
          say "JOIN ##{self.chan}"
        when "366"
          puts "[INFO]>> Successfully joined ##{self.chan}"
        else
        end
      end
      #output to terminal window whatever the server is giving our socket\
      puts "[SERVER]<< #{msg.stringify}" if @verbose
    end
  end

end

bot = Bot.new("hirugabotto", "irc.rizon.net", 6667, "bbtest", true)
bot.run()