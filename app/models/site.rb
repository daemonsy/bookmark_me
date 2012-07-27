class Site < ActiveRecord::Base
  
  make_me_searchable :fields => [:name, :description, :hostname]
  
  
  # Associations
  has_many :bookmarks, :dependent => :destroy
  validates_presence_of :hostname
  
  after_create :set_site_meta_data
  
  # DO NOT validates_associated :bookmark.
  
  protected
  def set_site_meta_data
    begin
      page = Pismo::Document.new(self.hostname)
      self.name = page.html_title
      self.description = page.description
      self.save
    rescue => e
      self.description = "Error => #{e}"
    end
  end
  handle_asynchronously :set_site_meta_data
  
end
