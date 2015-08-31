require 'socket'
require_relative '../settings.rb'

module Irc

  attr_reader :nick, :server, :port, :chan, :verbose, :msg_cache
  attr_accessor :socket, :loaded_triggers, :last_match

    # Have an explicit initialize method, since calling super() is vague
    def init_irc(silent = false, chan)
      @nick = Settings::NICKNAME
      @server = Settings::SERVER
      @port = Settings::PORT
      @chan = chan || Settings::CHAN
      @last_resp = Time.now
      @loaded_triggers = {}
      @msg_cache = []
      @in_chan = false
    end

    # Hacky way of responding to server codes
    def respond_to_server(msg)
      if msg.parts[0] == "PING"
        say "PONG :pingis"
      else
        case msg.parts[1]
        when "001"
         $log.info("Processing connection to server...")
        when "376"
          $log.info("Connected to server, joining channel...")
          join_chan(@chan)
        when "366"
          @in_chan = true
          $log.info("Successfully joined ##{@chan}")
        else
        end
      end
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

    def load_triggers
      Settings::DEFAULT_TRIGGERS.each_key{ |k| load_trigger(k, true) }
      Settings::TRIGGERS.each_key{ |k| load_trigger(k) }
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
    end

    def unload_trigger(name)
      name = name.to_sym
      return if @loaded_triggers[name].nil?
      @loaded_triggers.delete(name)
      $log.info("Unloaded #{name}")
    end

    def list_loaded_triggers
      return if @loaded_triggers.empty?
      loaded_list = ""
      @loaded_triggers.each_key { |t| loaded_list += "#{t.to_s.capitalize}, " }
      $log.info("Currently loaded triggers: #{loaded_list[0..-3]}")
    end

    # Hold last N messages in memory, this can be changed but should be kept
    # at a reasonable number, depending on hardware. Also store in DB.
    # TODO: Migrate this to a Redis cache!
    def store_message(msg)
      return if msg.text == $bot.nick || msg.text.split[1] == "!"
      $log.info("Caching #{msg}: #{msg.text}")
      if @msg_cache.length >= 1000
        @msg_cache.shift
      end
        @msg_cache << msg
    end

    # Search through all triggers and send response if we get a match
    # Do this in "callback" style because for (un)loading triggers, we need to stop iteration.
    def fire_triggers(msg)
      found = nil
      @loaded_triggers.each do |name, trigger|
        if trigger.matched?(msg.text) && (Time.now - @last_resp).to_i > Settings::DELAY
          @last_resp = Time.now
          found = trigger
          break
        end
      end
      say_to_chan(@chan, found.respond) if found
    end

end
