class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.timestamps
    end

    add_index :users, :email, :unique => true

    create_table :interests do |t|
      t.string :category
      t.boolean :primary
      t.datetime :last_seen
      t.references :user
    end

    add_index :interests, :user_id

    create_table :models do |t|
      t.string :method
      t.references :interest
    end

    add_index :models, :interest_id

    create_table :model_params do |t|
      t.string :key
      t.float :value
      t.references :model
    end

    add_index :model_params, :model_id

    create_table :ratings do |t|
      t.integer :article_id
      t.integer :action
      t.references :user
    end

    add_index :ratings, :user_id
  end
end
