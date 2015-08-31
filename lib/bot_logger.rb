require 'logger'
require_relative '../settings.rb'
require 'MultiIO'

module BotLogger
  include Settings

  def init_bot_logger(silent = false, dev = false)
    log_file = File.open(Settings::LOG_FILE, File::WRONLY | File::APPEND)
    $log = Logger.new(new MultiIO(STDOUT, log_file), Settings::LOG_ROTATE)
    $log.level = (silent ? Logger::WARN : Logger::INFO)
  end

end

class MultiIO

  def initialize(*targets)
     @targets = targets
  end

  def write(*args)
    @targets.each {|t| t.write(*args)}
  end

  def close
    @targets.each(&:close)
  end

end
