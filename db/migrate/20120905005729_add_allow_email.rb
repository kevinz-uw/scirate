class AddAllowEmail < ActiveRecord::Migration
  def change
    add_column :users, :allow_email, :boolean
  end
end
