require 'pg'
require 'singleton'
require_relative '../../settings.rb'

class Database
  include Singleton

  def self.init_db(db_name = Settings::DB_NAME)
    @@conn = PG.connect(dbname: db_name)
    `psql #{db_name} < ./lib/db/schema.sql`
  end

  def self.store_quote(message)
    nickname = message.nickname
    text = message.text
    time = Time.now()
    store_quote!(nickname, hostname, quote, time)
  end

  def self.find_quote_by_username(nickname)
    return if nickname.nil?
    find_quote_by_username!(nickname)
  end

  private

  def find_quote_by_username!(nickname)
    statement = "SELECT message FROM user_quotes WHERE nickname = $1"
    @@conn.execute(statement, [nickname])
  end

  def self.store_quote!(nickname, text, time)
    values = [nickname, text, time]
    if values.include?(nil)
      $log.warn("Cannot store nil value from supplied array #{values}")
      return
    end
    @@conn.prepare('statement', 'INSERT INTO user_quotes (nickname, message, timestamp) VALUES ($1, $2, $3)')
    @@conn.exec_prepared('statement', values)
  end

  def store!()
    #
  end

end
