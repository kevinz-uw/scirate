class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :arxiv_id
      t.text :title
      t.text :abstract
      t.text :comments
      t.string :doi
      t.string :journal_ref
      t.string :report_no
      t.string :submitter
      t.string :primary_category
      t.string :msc_class
      t.string :acm_class
      t.datetime :published
      t.datetime :last_updated
    end

    add_index :articles, :arxiv_id, :unique => true
    add_index :articles, :published
    add_index :articles, :last_updated

    create_table :authors do |t|
      t.string :name
      t.string :institution
      t.references :article
    end

    add_index :authors, :article_id

    create_table :categories do |t|
      t.string :name
      t.references :article
    end

    add_index :categories, :article_id

    create_table :versions do |t|
      t.string :name
      t.string :size
      t.datetime :timestamp
      t.references :article
    end

    add_index :versions, :article_id
  end
end
