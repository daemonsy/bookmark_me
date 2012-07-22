class Bookmark < ActiveRecord::Base
  ##
  # Not going to validate the URL is well formed. Following some user modeling, I feel that at minimum a bookmark entry should always be saved.
  # User should never lose data after pressing save as much as possible.
  
  # URL Cases
  # "http://localhost:3000/api/v1/users.json?q=12345&b=12345&time=20070301"
  # Chinese character URIs 
  # IP Addresses 
  # Local host with ports

  acts_as_taggable
  ActsAsTaggableOn.remove_unused_tags = true
  
  # Comes from a gem wrote for this exercise. Very fragile.
  make_me_searchable :fields => [:name,:description, :full_url]
  

  # Accessors and Accessible
  attr_accessible :full_url,:tag_tokens
  attr_accessor :full_hostname
  attr_reader :tag_tokens
  
  # Associations
  belongs_to :site
  
  
  
  # Validations
  validates_presence_of :full_url, :message=> "is required for bookmarking."
  validates_associated :site
  
  # Callbacks 
  before_save :find_or_create_new_site_for_bookmark
  
  # Callbacks are triggered infinitely if the process is not in delayed_job. Seek for a better solution
  # I tried using if on the dirty tracking, but it seems its always called.
  after_save :callbacks_to_run_if_full_url_changed
  
    
  # Getters and Setters
  def full_hostname
    read_attribute(:full_hostname) || self.parse_full_url_to_set_full_hostname_only
  end
  
  def tag_tokens=(tags)
    # Tag tokens is a method for the JS script to pass in a comma delimited string of tag names
    if tags.present?
      self.tag_list = []
      self.tag_list << tags.split(",").reject{|t|t.empty?}
    end
  end

  # Callbacks
  def find_or_create_new_site_for_bookmark
    # UPDATE The search for the site will go by full url. If not found, it will look to see if there's one without www.
    # Creation is only done if both the above are not available. It is a bit unreasonable for me to assume all urls should be stored in the non-www form. 
    # Sometimes they might be different sites (usually the non-www version returns an error for SG government services). 

    # The thing is, usually users will not bookmark a bad URL unless they are typing by hand. The next iteration should instead focus on whether the URL returns a 404 or redirect instead
    # of making assumptions
    if self.full_url_changed? 
      site = Site.find_or_create_by_hostname(self.full_hostname)
      self.site = site
    end
  end
  
  def callbacks_to_run_if_full_url_changed
    if self.full_url_changed?
      self.set_short_url            # Set URL using Bitly.
      self.set_bookmark_meta_data   # Crawl page for title
    end
  end
  
  
  protected
  # Methods used internally only by other methods
  def set_bookmark_meta_data
    begin
      page = Pismo::Document.new(self.full_url)
      self.name = page.html_title
      self.favicon_url = page.favicon
      self.description = page.description
    rescue => e
      self.description = "Error => #{e}"
    ensure
      self.save
    end
  end
  handle_asynchronously :set_bookmark_meta_data
  
  def set_short_url
    begin
      self.short_url =  BITLY_SVC.shorten(self.full_url).short_url
    rescue => e
      self.short_url = "Error with message => #{e}"
    ensure 
      self.save
    end
  end
  handle_asynchronously :set_short_url
  
  def parse_full_url_to_set_full_hostname_only # Sets the URI accessors 
    # Parse the URI. Defaults to "http" for scheme if it's not present for URI to handle it. This also sets the full_url with a default "http://" if not present.
    begin
      uri = URI.parse(self.full_url)
      uri = URI.parse("http://#{self.full_url}") and self.full_url = uri.to_s if uri.scheme.nil?
      if uri.host.present? # Still need to check if uri has a host
        uri.path = ''
        uri.query, uri.fragment = nil # TODO => Check this for safety
      end
      self.full_hostname = uri.to_s
    rescue
      nil
    end
  end
  
  
end
