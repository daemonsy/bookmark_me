class Bookmark < ActiveRecord::Base
  ##
  # Not going to validate the URL is well formed. Following my user modeling, I feel that at minimum a bookmark entry should always be saved. The bookmark app can be used as a blind text store by users.
  # Scheme, Host and port
  
  # Test Strings
  # "http://localhost:3000/api/v1/users.json?q=12345&b=12345&time=20070301"
  # Chinese character URIs 
  # IP Addresses 
  # Local host with ports
  # Basically it will be good if I can find a great gem to handle all the different cases in URIs. 
  acts_as_taggable
  # includes "Search"
  # def self.make_me_searchable(options = {})
  #   @fields = options[:fields]
  # end
  
  # def self.search(query)
  #   search = Search.new(@fields)

  #   @fields.each do |field|
  #     search_results += self.where("#{field} LIKE ?", "%#{query}%")
  #   end
  #   search.results = search_results
  #   search
  # end
  
  make_me_searchable :fields => :name
  

  # Accessors and Accessible
  attr_accessible :full_url,:tag_tokens
  attr_accessor :full_hostname_without_www, :full_path
  attr_reader :tag_tokens
  
  # Associations
  belongs_to :site
  # has_and_belongs_to_many :tags
  
  accepts_nested_attributes_for :tags, :allow_destroy => true, :reject_if => proc { |obj| obj.blank? }
  
  # Validations
  validates_presence_of :full_url
  
  # Callbacks 
  before_save :find_or_create_new_site_for_bookmark, :if => :full_url_changed?
  
  # Callbacks are triggered infinitely if the process is not in delayed_job. Seek for a better solution
  # I tried using if on the dirty tracking, but it seems its always called.
  after_save :callbacks_to_run_if_full_url_changed, :if => :full_url_changed?
  
    
  # Getters and Setters
  def full_hostname_without_www
    read_attribute(:full_host_name_without_www) || self.parse_full_url_to_set_full_hostname_without_www
  end
  
  
  
  def full_url=(val)
    # Have a custom setter for full_url => basic treatment like downcase(or e.g. handling characters?) can be done before passing to methods for other higher level treatments.
    val = val.downcase
    write_attribute(:full_url,val)
  end
  
  
  def tag_tokens=(tags)
    if tags.present?
      self.tag_list << tags.split(",").reject{|t|t.empty?}
    end
  end

  # Callbacks
  def find_or_create_new_site_for_bookmark
    # Pass to site class, check if such a site exists using only the host name
    if self.full_url_changed?
      puts "in full url changed trying to save"    
      site = self.full_hostname_without_www.present? ? Site.find_or_create_by_hostname(self.full_hostname_without_www) : Site.find_or_create_by_hostname(self.full_url) # Does not try to remove www if hostname is not well formed
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
      self.short_url = "Oops. Error with message => #{e}"
    ensure 
      self.save
    end
  end
  handle_asynchronously :set_short_url
  
  def parse_full_url_to_set_full_hostname_without_www # Sets the URI accessors 
    # Parse the URI. Defaults to "http" for scheme if it's not present for URI to handle it. This also sets the full_url with a default "http://" if not present.
    begin
      uri = URI.parse(self.full_url)
      uri = URI.parse("http://#{self.full_url}") and self.full_url = uri.to_s if uri.scheme.nil?
      if uri.host.present? # Still need to check if uri has a host
        uri.path = ''
        uri.query, uri.fragment = nil # TODO => Check this for safety
      end
      self.full_hostname_without_www = uri.to_s
    rescue
      nil
    end
  end
  
  
end
