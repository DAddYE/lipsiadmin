class CreateMenus < ActiveRecord::Migration
  def self.up
    create_table :menus, :force => true do |t|
      t.string   :name
      t.boolean  :admin, :default => false
      t.integer  :position
      t.text     :options
      t.timestamps
    end
    
    Menu.create(:name => "Accounts", :admin => true, :position => 1)
  end

  def self.down
    drop_table "accounts"
  end
end