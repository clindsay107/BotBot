require 'logger'

module BotLogger

  def init_bot_logger(silent = false)
    log_file = File.open("../tmp/debug.log", File::WRONLY | File::APPEND)
    # $log = Logger.new(STDOUT)
    $log = Logger.new(log_file, "monthly")
    $log.level = (silent ? Logger::WARN : Logger::INFO)
  end

end
