class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments, :force => true do |t|
      t.string     :attached_file_name, 
      t.string     :attached_content_type
      t.integer    :attached_file_size
      t.references :attacher,             :polymorphic => true
      t.string     :attacher_name
      t.integer    :position,             :default => 1
      t.timestamps
    end
  end

  def self.down
    drop_table :attachments
  end
end
