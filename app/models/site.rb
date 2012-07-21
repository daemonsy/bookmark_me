class Site < ActiveRecord::Base
  # attr_accessible :title, :body
  # has a hostname, will treat www and without www as the same site.
  
  # Associations
  has_many :bookmarks, :dependent => :destroy
  
  #def self.find_or_create_by_hostname_after_removing_www(hostname)
  #  # Remove www. if present
  #  self.find_or_create_by_hostname(hostname.sub(/www\./,''))
  #end
  
end
