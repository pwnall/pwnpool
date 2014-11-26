class DockerHostsController < ApplicationController
  before_action :set_docker_host, only: [:show, :edit, :update, :destroy]

  # GET /docker_hosts
  # GET /docker_hosts.json
  def index
    @docker_hosts = DockerHost.all
  end

  # GET /docker_hosts/1
  # GET /docker_hosts/1.json
  def show
  end

  # GET /docker_hosts/new
  def new
    @docker_host = DockerHost.new
  end

  # GET /docker_hosts/1/edit
  def edit
  end

  # POST /docker_hosts
  # POST /docker_hosts.json
  def create
    @docker_host = DockerHost.new(docker_host_params)

    respond_to do |format|
      if @docker_host.save
        format.html { redirect_to @docker_host, notice: 'Docker host was successfully created.' }
        format.json { render :show, status: :created, location: @docker_host }
      else
        format.html { render :new }
        format.json { render json: @docker_host.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /docker_hosts/1
  # PATCH/PUT /docker_hosts/1.json
  def update
    respond_to do |format|
      if @docker_host.update(docker_host_params)
        format.html { redirect_to @docker_host, notice: 'Docker host was successfully updated.' }
        format.json { render :show, status: :ok, location: @docker_host }
      else
        format.html { render :edit }
        format.json { render json: @docker_host.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /docker_hosts/1
  # DELETE /docker_hosts/1.json
  def destroy
    @docker_host.destroy
    respond_to do |format|
      format.html { redirect_to docker_hosts_url, notice: 'Docker host was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_docker_host
      @docker_host = DockerHost.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def docker_host_params
      params.require(:docker_host).permit(:user_id, :url, :ssl_cert)
    end
end
