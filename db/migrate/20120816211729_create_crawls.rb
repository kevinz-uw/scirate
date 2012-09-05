class CreateCrawls < ActiveRecord::Migration
  def change
    create_table :crawls do |t|
      t.datetime :finished
      t.datetime :max_published
      t.datetime :max_updated
    end

    add_index :crawls, :finished
  end
end
