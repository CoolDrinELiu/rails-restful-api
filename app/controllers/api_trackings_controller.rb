class ApiTrackingsController < ApplicationController
  # GET /api_trackings
  # GET /api_trackings.json
  def index
    @api_trackings = ApiTracking.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @api_trackings }
    end
  end

  # GET /api_trackings/1
  # GET /api_trackings/1.json
  def show
    @api_tracking = ApiTracking.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @api_tracking }
    end
  end

  # GET /api_trackings/new
  # GET /api_trackings/new.json
  def new
    @api_tracking = ApiTracking.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @api_tracking }
    end
  end

  # GET /api_trackings/1/edit
  def edit
    @api_tracking = ApiTracking.find(params[:id])
  end

  # POST /api_trackings
  # POST /api_trackings.json
  def create
    @api_tracking = ApiTracking.new(params[:api_tracking])

    respond_to do |format|
      if @api_tracking.save
        format.html { redirect_to @api_tracking, notice: 'Api tracking was successfully created.' }
        format.json { render json: @api_tracking, status: :created, location: @api_tracking }
      else
        format.html { render action: "new" }
        format.json { render json: @api_tracking.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /api_trackings/1
  # PUT /api_trackings/1.json
  def update
    @api_tracking = ApiTracking.find(params[:id])

    respond_to do |format|
      if @api_tracking.update_attributes(params[:api_tracking])
        format.html { redirect_to @api_tracking, notice: 'Api tracking was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @api_tracking.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api_trackings/1
  # DELETE /api_trackings/1.json
  def destroy
    @api_tracking = ApiTracking.find(params[:id])
    @api_tracking.destroy

    respond_to do |format|
      format.html { redirect_to api_trackings_url }
      format.json { head :no_content }
    end
  end
end
