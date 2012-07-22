class AddFaviconUrlAndDescriptionToBookmark < ActiveRecord::Migration
  def self.up
    add_column :bookmarks, :favicon_url, :string
    add_column :bookmarks, :description, :text
  end

  def self.down
    remove_column :bookmarks, :description
    remove_column :bookmarks, :favicon_url
  end
end