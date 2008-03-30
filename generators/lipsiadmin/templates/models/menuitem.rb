class Menuitem < ActiveRecord::Base
  validates_presence_of     :name, :url, :menu
  validates_numericality_of :position
end