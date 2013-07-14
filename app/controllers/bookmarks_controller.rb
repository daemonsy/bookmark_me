class BookmarksController < ApplicationController
  before_filter :assign_tag_tokens_params_if_present

  def assign_tag_tokens_params_if_present
    # TODO This assignment is because the JS plugin does not handle submission elegantly. The plugin did not have to rename the target textfield, but it did.
    # In order not to edit the plugin's code, this is currently a fix by direct assignment.
    params[:bookmark][:tag_tokens] = params[:as_values_tag_tokens] if params[:as_values_tag_tokens].present?
  end

  def search
    # Will look through information in Site model, but does not separate the results into sites / bookmarks.
    # The user model envisioned is interaction with bookmarks.
    @search = Bookmark.search(params[:q])
    @bookmarks = @search.results.paginate(:page=>params[:page])
    respond_to do |format|
      format.html {render :action => :index}
      format.json {render json: @bookmarks}
    end
  end

  def index
    @bookmarks = Bookmark.paginate(:page=> params[:page], :per_page=>20)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bookmarks }
    end
  end

  def show
    @bookmark = Bookmark.find(params[:id], :include=>{:site=>:bookmarks})
    @site_bookmarks = @bookmark.site.bookmarks - [@bookmark] # @bookmark.site.bookmarks should always return you an empty array and not nil

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @bookmark }
    end
  end

  def new
    @bookmark = Bookmark.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @bookmark }
    end
  end

  def edit
    @bookmark = Bookmark.find(params[:id])
  end

  def create
    @bookmark = Bookmark.find_or_initialize_by_full_url(bookmark_params[:full_url])
    @bookmark.attributes= params[:bookmark]

    respond_to do |format|
      if @bookmark.save
        format.html { redirect_to @bookmark, notice: 'Crawling Bookmark URL. Page will refresh in 5 seconds.'}
        format.json { render json: @bookmark, status: :created, location: @bookmark }
      else
        format.html { render action: "new" }
        format.json { render json: @bookmark.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @bookmark = Bookmark.find(params[:id])

    respond_to do |format|
      if @bookmark.update_attributes(bookmark_params)
        format.html { redirect_to @bookmark, notice: 'Bookmark was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @bookmark.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @bookmark = Bookmark.find(params[:id])
    @bookmark.destroy

    respond_to do |format|
      format.html { redirect_to bookmarks_url }
      format.json { head :no_content }
    end
  end
  private

  def bookmark_params
    params.require(:bookmark).permit(:tag_tokens, :full_url)
  end
end
