class Attachment < ActiveRecord::Migration
  def self.up
    create_table :attachment, :force => true do |t|
      t.string  :attached_file_name, :attached_content_type
      t.integer :attached_file_size
      t.timestamps
    end
  end

  def self.down
    drop_table :attachment
  end
end
