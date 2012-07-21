class CreateBookmarksTags < ActiveRecord::Migration
  def self.up
    create_table :bookmarks_tags, :id=>false do |t|
      t.references :bookmark
      t.references :tag
    end
  end

  def self.down
    drop_table :bookmarks_tags
  end
end