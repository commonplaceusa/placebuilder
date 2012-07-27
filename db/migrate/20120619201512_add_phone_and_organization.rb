class AddPhoneAndOrganization < ActiveRecord::Migration
  def up
    add_column :residents, :phone, :integer
    add_column :residents, :organization, :string
  end
  def down
    remove_column :residents, :phone, :integer
    remove_column :residents, :organization, :string
  end
end
