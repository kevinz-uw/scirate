class AddScitesCount < ActiveRecord::Migration
  def change
    add_column :articles, :scites, :integer

    # NOTE: We include both orders of scites/publisehd in order to make
    #   browsing efficient whether or not a time range is included.
    # TODO(future): Figure out whether we can do this for all listed categories.
    add_index :articles, [:primary_category, :scites, :published]
    add_index :articles, [:primary_category, :published, :scites]
  end
end
