class CreateFrontCarrousels < ActiveRecord::Migration
  def self.up
    create_table :front_carrousels do |t|
      t.string :link
      t.string :label
      t.has_attached_file :photo
      t.integer :position
      t.boolean  :active, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :front_carrousels
  end
end