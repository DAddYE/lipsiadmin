class StateSession < ActiveRecord::Base
  belongs_to :account
  validates_presence_of :account_id, :component
end