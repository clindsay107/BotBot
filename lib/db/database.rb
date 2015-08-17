include 'pg'
include 'singleton'
require_relative '../../settings.rb'

class Database
  include Singleton
  include Settings

  attr_reader :conn

  def initialize(db_name = Settings::DB_NAME)
    @conn = db_name
    setup()
  end

  private

  def setup()
    #
  end

end
