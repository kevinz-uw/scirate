class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :activity
      t.datetime :at
      t.float :duration
      t.references :user
    end

    add_index :events, :activity
    add_index :events, :at

    create_table :event_params do |t|
      t.string :key
      t.text :str_value  # could be very long (e.g., a stack trace)
      t.integer :int_value
      t.float :float_value
      t.references :event
    end

    add_index :event_params, :event_id
  end
end
