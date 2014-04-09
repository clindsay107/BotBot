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
  attr_accessor :socket, :loaded_triggers, :last_match

  def initialize(silent = false)
    @nick = Settings::NICKNAME
    @server = Settings::SERVER
    @port = Settings::PORT
    @chan = Settings::CHAN
    @last_resp = Time.now
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
    return if str.nil?
    if !@in_chan
      $log.warn("Not in channel, but tried to send text to #{@chan}")
      return
    end
    say("PRIVMSG ##{chan} :#{str.strip}") if str
  end

  def join_chan(chan)
    $log.info("Joining ##{chan}")
    say("JOIN ##{chan}")
  end

  def leave_chan(chan)
    $log.info("Leaving ##{chan}")
    say("PART ##{chan}")
  end

  def load_trigger(name, defaults = false)
    name = name.to_sym
    if defaults
      return if !Settings::DEFAULT_TRIGGERS[name]
      @loaded_triggers[name] = Settings::DEFAULT_TRIGGERS[name]
    else
      return if !Settings::TRIGGERS[name]
      @loaded_triggers[name] = Settings::TRIGGERS[name]
    end
    $log.info("Loaded #{name}")
    "#{name} successfully loaded!"
  end

  def unload_trigger(name)
    name = name.to_sym
    return if @loaded_triggers[name].nil?
    @loaded_triggers.delete(name)
    $log.info("Unloaded #{name}")
    "#{name} successfully unloaded!"
  end

  def list_loaded_triggers
    return if @loaded_triggers.empty?
    loaded_list = ""
    @loaded_triggers.each_key { |t| loaded_list += "#{t.to_s.capitalize}, " }
    "Currently loaded triggers: #{loaded_list[0..-3]}"
  end

  #hold last N messages in memory, this can be changed but should be kept
  #at a reasonable number, depending on hardware. Also store in DB.
  def cache_message(msg)
    # @conn.prepare("insert_quote", "INSERT INTO quotes (nickname, message, date_added) VALUES ($1, $2)")
    # @conn.exec_prepared("insert_quote", [msg.nickname, msg.text, Time.now])
    return if msg.text == $bot.nick
    $log.info("Caching #{msg}: #{msg.text}")
    if @msg_cache.length >= 500
      @msg_cache.shift
      @msg_cache << msg
    else
      @msg_cache << msg
    end
  end

  #Search through all triggers and send response if we get a match
  #Do this in "callback" style because for (un)loading triggers, we need to stop iteration.
  def fire_triggers(msg)
    found = nil
    @loaded_triggers.each do |name, trigger|
      if trigger.matched?(msg.text) && (Time.now - @last_resp).to_i > Settings::DELAY
        @last_resp = Time.now
        found = trigger
        break
        #return say_to_chan(self.chan, trigger.send_response)
      end
    end
    say_to_chan(self.chan, found.send_response) if found
  end


  #Open a TCPSocket and connect, joining the channel when appropriate.
  #Turn on verbose logging if declared in init (helpful for debugging)
  def run
    Settings::DEFAULT_TRIGGERS.each_key{|k| load_trigger(k, true)}
    Settings::TRIGGERS.each_key{|k| load_trigger(k)}
    @socket = TCPSocket.open(self.server, self.port)

    $log.info("Initiating handshake with server...")
    say "USER #{nick} 0 * #{nick}"
    say "NICK #{nick}"

    until @socket.eof? do
      msg = @socket.gets
      msg = (msg.split(" ")[1] == "PRIVMSG" ? PrivateMessage.new(msg) : Message.new(msg))

      if msg.type == "PRIVMSG"
        cache_message(msg)
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
          join_chan(self.chan)
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