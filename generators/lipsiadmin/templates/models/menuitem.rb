class Menuitem < ActiveRecord::Base
  validates_presence_of :name, :url, :menu_id
  belongs_to :menu
end