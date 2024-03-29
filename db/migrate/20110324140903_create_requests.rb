class CreateRequests < ActiveRecord::Migration
  def self.up
    create_table :requests do |t|
      t.string :community_name
      t.string :name
      t.string :email
      t.string :sponsor_organization
      t.timestamps
    end
  end

  def self.down
    drop_table :requests
  end
end
