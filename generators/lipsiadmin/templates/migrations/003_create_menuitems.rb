class CreateMenuitems < ActiveRecord::Migration
  def self.up
    create_table :menuitems, :force => true do |t|
      t.string     :name, :url, :style
      t.references :menu
      t.integer    :position
      t.timestamps
    end
    
    Menuitem.create(:name => "New Account", :url => "/admin/accounts/new", 
                    :menu_id => 1, :position => 1, :style => "icon-no-group")
    Menuitem.create(:name => "List Accounts", :url => "/admin/accounts/list", 
                    :menu_id => 1, :position => 2, :style => "icon-show-all")
  end

  def self.down
    drop_table "accounts"
  end
end