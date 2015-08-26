require 'logger'
require_relative '../settings.rb'

module BotLogger
  include Settings

  def init_bot_logger(silent = false)
    log_file = File.open(Settings::LOG_FILE, File::WRONLY | File::APPEND)
    $log = Logger.new(log_file, SETTINGS::LOG_ROTATE)
    $log.level = (silent ? Logger::WARN : Logger::INFO)
  end

end
