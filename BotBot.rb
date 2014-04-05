#!/usr/bin/env ruby

require 'socket'
require 'logger'
require 'singleton'
Dir[File.join(".", "lib/*.rb")].each { |f| require f }

class Bot
  attr_reader :nick, :server, :port, :chan, :verbose, :msg_cache
  attr_accessor :socket, :loaded_triggers

  def initialize(nick, server, port, chan, silent = false)
    @nick = nick
    @server = server
    @port = port
    @chan = chan
    @loaded_triggers = {}
    @msg_cache = []

    log_file = File.open("log/debug.log", "w")
    $log = Logger.new(MultiWriter.new(STDOUT, log_file))
    $log.level = (silent ? Logger::WARN : Logger::INFO)
  end

  def say(str)
    @socket.puts("#{str}\n")
  end

  def say_to_user(user, str)
    say("PRIVMSG #{user} :#{str}")
  end

  def say_to_chan(chan, str)
    say("PRIVMSG ##{chan} :#{str}")
  end

  def load_trigger(trigger)
    return if @loaded_triggers[trigger.name]
    @loaded_triggers[trigger.name] = trigger
    $log.info("Loaded #{trigger.name}")
    #say_to_chan(self.chan, "#{trigger.name} successfully unloaded!")
  end

  def unload_trigger(trigger)
    return if @loaded_triggers[triggername].nil?
    @loaded_triggers.delete(trigger.name)
    $log.info("Unloaded #{trigger.name}")
    #say_to_chan(self.chan, "#{trigger.name} successfully loaded!")
  end

  def list_loaded_triggers
    return if @loaded_triggers.empty?
    loaded_list = ""
    @loaded_triggers.each_key { |t| loaded_list += " #{t.to_s}," }
    say_to_chan(self.chan, loaded_list)
  end

  #hold last N messages in memory, this can be changed but should be kept
  #at a reasonable number, depending on hardware
  def add_to_cache(msg)
    return if msg.text.split[0] == $bot.nick
    if @msg_cache.length >= 500
      @msg_cache.shift
      @msg_cache << msg
    else
      @msg_cache << msg
    end
  end


  #Open a TCPSocket and connect, joining the channel when appropriate.
  #Turn on verbose logging if declared in init (helpful for debugging)
  def run
    @socket = TCPSocket.open(self.server, self.port)
    $log.info("Initiating handshake with server...")
    say "USER #{nick} 0 * #{nick}"
    say "NICK #{nick}"

    until @socket.eof? do
      msg = @socket.gets
      msg = (msg.split(" ")[1] == "PRIVMSG" ? PrivateMessage.new(msg) : Message.new(msg))

      if msg.type == "PRIVMSG"
        add_to_cache(msg)
        @loaded_triggers.each do |name, trigger|
          if trigger.matched?(msg.text)
            say_to_chan(self.chan, trigger.send_response)
          end
        end
      end

      #keep alive
      if msg.parts[0] == "PING"
        say "PONG :pingis"
      else
        case msg.parts[1]
        when "001"
         $log.info("Processing connection to server...")
        when "376"
          $log.info("Connected to server, joining channel...")
          say "JOIN ##{self.chan}"
        when "366"
          $log.info("Successfully joined ##{self.chan}")
        else
        end
      end
      #output to terminal window whatever the server is giving our socket
      $log.info("#{msg.stringify}")
    end
  end

end

#a class which can handle writing to multiple IO targets
# http://stackoverflow.com/a/6407200/3495138
class MultiWriter

  def initialize(*targets)
    @targets = targets
  end

  def write(*args)
    @targets.each { |t| t.write(*args) }
  end

  def close
    @targets.each(&:close)
  end
end

$bot = Bot.new("hirugabotto", "irc.rizon.net", 6667, "lifting")
markov = Markov.new($bot.nick, Proc.new{Markov.markov_response})
$bot.load_trigger(markov)
$bot.run()