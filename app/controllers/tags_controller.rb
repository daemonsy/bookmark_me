class TagsController < ApplicationController
  def search
    if params[:q]
      @tags = Bookmark.tag_counts_on(:tags).where("name like ?", "%#{params[:q]}%") 
    end
    
    respond_to do |format|
      format.json {render :json => @tags, :only=>[:id,:name] }
    end
  end
  
  def index
    @tag = ActsAsTaggableOn::Tag.find_by_name(params[:name])
    @bookmarks = Bookmark.tagged_with(@tag)
    respond_to do |format|
      format.html
    end
  end
end