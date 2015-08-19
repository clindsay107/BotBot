require 'logger'

module BotLogger

  def init_bot_logger(silent = false)
    # log_file = File.open("../tmp/debug.log", "w")
    $log = Logger.new(STDOUT)
    $log.level = (silent ? Logger::WARN : Logger::INFO)
  end

end
