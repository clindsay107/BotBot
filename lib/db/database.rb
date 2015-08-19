include 'pg'
include 'singleton'
require_relative '../../settings.rb'

class Database
  include Singleton
  include Settings

  def initialize(db_name = Settings::DB_NAME)
    @conn = PG.connect(dbname: db_name)
    setup()
  end

  def store_quote(quote)

  end

  def find_by_username(nickname)
    return if nickname.nil?
    find_by_username!(nickname)
  end

  private

  def setup()
    file = File.open('./schema.txt')
    schema = file.read

    @conn.execute(schema)
  end

  def find_by_username!(nickname)
    statement = "SELECT message FROM user_quotes WHERE nickname = $1"
    @conn.execute(statement, [nickname])
  end

  def store!()
    #
  end

end
