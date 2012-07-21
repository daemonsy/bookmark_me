class CreateBookmarks < ActiveRecord::Migration
  def change
    create_table :bookmarks do |t|
      t.references    :site
      t.string        :name # For page title
      t.string        :full_url
      t.string        :short_url
      t.timestamps
    end
  end
end
