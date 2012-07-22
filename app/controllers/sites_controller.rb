class SitesController < ApplicationController
  # POST /sites/search
  def search
    @search = Site.search(params[:q])
    @sites = @search.results.paginate(:page=>params[:page])
    respond_to do |format|
      format.html {render :action=>:index}
    end
  end
  
  # GET /sites
  # GET /sites.json
  def index
    @sites = Site.paginate(:page=>params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sites }
    end
  end

  # GET /sites/1
  # GET /sites/1.json
  def show
    @site = Site.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @site }
    end
  end
  
  


  # DELETE /sites/1
  # DELETE /sites/1.json
  def destroy
    @site = Site.find(params[:id])
    @site.destroy

    respond_to do |format|
      format.html { redirect_to sites_url }
      format.json { head :no_content }
    end
  end
end
