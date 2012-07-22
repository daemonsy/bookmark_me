class Site < ActiveRecord::Base
  
  make_me_searchable :fields => [:name, :description, :hostname]
  
  
  # Associations
  has_many :bookmarks, :dependent => :destroy
  
  after_create :set_site_meta_data
  
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
