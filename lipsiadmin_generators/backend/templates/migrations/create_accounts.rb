class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts, :force => true do |t|
      t.string      :name, :surname, :email, :salt, :crypted_password, :role, :modules
      t.timestamps
    end

    # I'll create the first account
    Account.create({:email => "info@lipsiasoft.com", 
                    :name => "Davide", 
                    :surname => "D'Agostino",
                    :password => "admin", 
                    :password_confirmation => "admin", 
                    :role => "administrator" })
  end

  def self.down
    drop_table "accounts"
  end
end