class CreateMenuitems < ActiveRecord::Migration
  def self.up
    create_table :menuitems, :force => true do |t|
      t.string     :name, :url, :style, :menu
      t.integer    :position
      t.boolean    :admin, :default => false
      t.timestamps
    end
    
    Menuitem.create(:name => "Accounts", :url => "/admin/accounts/list", :menu => "Administration",
                    :position => 1, :admin => true, :style => "icon-no-group")

    Menuitem.create(:name => "Menus", :url => "/admin/menuitems/list", :menu => "Administration",
                    :position => 2, :admin => true, :style => "icon-no-group")
  end

  def self.down
    drop_table :menuitems
  end
end