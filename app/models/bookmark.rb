class Bookmark < ActiveRecord::Base
  # Not going to validate the URL is well formed. Following my user modeling, I feel that at minimum a bookmark entry should always be saved. The bookmark app can be used as a blind text store by users.
  # Scheme, Host and port
  
  # Test Strings
  # "http://localhost:3000/api/v1/users.json?q=12345&b=12345&time=20070301"
  # Chinese character URIs 
  # IP Addresses 
  # Local host with ports
  # Basically it will be good if I can find a great gem to handle all the different cases in URIs. 
  
  attr_accessible :full_url
  attr_accessor :full_hostname_without_www, :full_path
  
  # Associations
  belongs_to :site
  has_and_belongs_to_many :tags
  
  accepts_nested_attributes_for :tags, :allow_destroy => true, :reject_if => proc { |obj| obj.blank? }
  
  # Callbacks 
  before_save :find_or_create_new_site_for_bookmark
  
  
  # Getters 
  def full_hostname_without_www  # Declared for completeness
    self.parse_full_url_to_set_full_hostname_without_www
  end
  
  # Setters
  def full_url=(val)
    # Have a custom setter for full_url because I beleive basic treatment like downcase(or e.g. handling characters?) can be done here before passing to methods for other higher level treatments.
    val = val.downcase 
    write_attribute(:full_url,val)
  end
  
  def find_or_create_new_site_for_bookmark
    # Pass to site class, check if such a site exists using only the host name    
    site = self.full_hostname_without_www.present? ? Site.find_or_create_by_hostname(self.full_hostname_without_www) : Site.find_or_create_by_hostname(self.full_url) # Does not try to remove www if hostname is not well formed
    self.site = site
  end
  
  protected
  
  # Methods used internally only by other methods
  def parse_full_url_to_set_full_hostname_without_www # Sets the URI accessors 
    # Parse the URI. Defaults to "http" for scheme if it's not present. Otherwise, URI will not be able to handle it.
    uri = URI.parse(self.full_url)
    uri = URI.parse("http://#{self.full_url}") if uri.scheme.nil?
    
    if uri.host.present? # Still need to check if uri has a host
      uri.path = ''
      uri.query, uri.fragment = nil # TODO => Check this for safety
      uri.host = uri.host.sub(/\Awww\./,'') 
    end
    self.full_hostname_without_www = uri.to_s
  end
  
  
end
