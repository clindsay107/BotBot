#!/usr/bin/env ruby

require 'socket'
require 'logger'
require 'singleton'
require 'pg'
require_relative 'settings'
Dir[File.join(".", "lib/*.rb")].each { |f| require f }

class Bot
  include Settings
  
  attr_reader :nick, :server, :port, :chan, :verbose, :msg_cache
  attr_accessor :socket, :loaded_triggers

  def initialize(silent = false)
    @nick = Settings::NICKNAME
    @server = Settings::SERVER
    @port = Settings::PORT
    @chan = Settings::CHAN
    @loaded_triggers = {}
    @msg_cache = []
    @in_chan = false

    log_file = File.open("tmp/debug.log", "a")
    $log = Logger.new(MultiWriter.new(STDOUT, log_file))
    $log.level = (silent ? Logger::WARN : Logger::INFO)

    # @conn = PG::Connection.open(dbname: 'botbot')
    # @conn.exec("CREATE TABLE quotes (
    #   id bigserial primary key, 
    #   nickname varchar(25) NOT NULL, 
    #   message text NOT NULL, 
    #   date_added timestamp NOT NULL)")
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
    say_to_chan(self.chan, "#{trigger.name} successfully unloaded!") if @in_chan
  end

  def unload_trigger(trigger)
    return if @loaded_triggers[triggername].nil?
    @loaded_triggers.delete(trigger.name)
    $log.info("Unloaded #{trigger.name}")
    say_to_chan(self.chan, "#{trigger.name} successfully loaded!") if @in_chan
  end

  def list_loaded_triggers
    return if @loaded_triggers.empty?
    loaded_list = ""
    @loaded_triggers.each_key { |t| loaded_list += " #{t.to_s}," }
    say_to_chan(self.chan, loaded_list)
  end

  #hold last N messages in memory, this can be changed but should be kept
  #at a reasonable number, depending on hardware. Also store in DB.
  def store_message(msg)
    # @conn.prepare("insert_quote", "INSERT INTO quotes (nickname, message, date_added) VALUES ($1, $2)")
    # @conn.exec_prepared("insert_quote", [msg.nickname, msg.text, Time.now])
    return if msg.text == $bot.nick
    if @msg_cache.length >= 500
      @msg_cache.shift
      @msg_cache << msg
    else
      @msg_cache << msg
    end
  end

  #search through all triggers and send response if we get a match
  def fire_triggers(msg)
    @loaded_triggers.each do |name, trigger|
      if trigger.matched?(msg.text)
        say_to_chan(self.chan, trigger.send_response)
        return #only fire one trigger per match, no spam!
      end
    end
  end


  #Open a TCPSocket and connect, joining the channel when appropriate.
  #Turn on verbose logging if declared in init (helpful for debugging)
  def run
    Settings::DEFAULT_TRIGGERS.each_value{|v| load_trigger(v)}
    @socket = TCPSocket.open(self.server, self.port)
    $log.info("Initiating handshake with server...")
    say "USER #{nick} 0 * #{nick}"
    say "NICK #{nick}"

    until @socket.eof? do
      msg = @socket.gets
      msg = (msg.split(" ")[1] == "PRIVMSG" ? PrivateMessage.new(msg) : Message.new(msg))

      if msg.type == "PRIVMSG"
        store_message(msg)
        fire_triggers(msg)
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
          @in_chan = true
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


$bot = Bot.new()
$bot.run()