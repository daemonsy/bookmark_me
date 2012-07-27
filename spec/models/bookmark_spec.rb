require 'spec_helper'

describe Bookmark do

  it "has a valid factory" do 
    FactoryGirl.create(:bookmark).should be_valid
  end
  
  it "is invalid without a full URL" do
    FactoryGirl.build(:bookmark, :full_url => nil).should_not be_valid
  end
    
  it "is invalid without a Site" do
    FactoryGirl.build(:bookmark, :site => nil).should_not be_valid
  end
  
  it "has many tags"

end
