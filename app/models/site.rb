class Site < ActiveRecord::Base
  # attr_accessible :title, :body
  # has a hostname, will treat www and without www as the same site.

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
