class CreateStateSessions < ActiveRecord::Migration
  def self.up
    create_table :state_sessions, :force => true do |t|
      t.references :account
      t.string     :component,   :null => false
      t.text       :data
    end
    
    add_index :state_sessions, :component
  end

  def self.down
    remove_index :state_sessions, :component
    drop_table :state_sessions
  end
end