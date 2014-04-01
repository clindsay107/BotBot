class CreateBots < ActiveRecord::Migration
  def change
    create_table :bots do |t|
      t.string :nickname
      t.string :password_hash
      t.string :server
      t.integer :port

      t.timestamps
    end
  end
end
