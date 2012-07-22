class Site < ActiveRecord::Base
  # attr_accessible :title, :body
  # has a hostname, will treat www and without www as the same site.
  
  # Associations
  has_many :bookmarks, :dependent => :destroy

  
end
