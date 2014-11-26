require 'test_helper'

class DockerHostsControllerTest < ActionController::TestCase
  setup do
    @docker_host = docker_hosts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:docker_hosts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create docker_host" do
    assert_difference('DockerHost.count') do
      post :create, docker_host: { ssl_cert: @docker_host.ssl_cert, url: @docker_host.url, user_id: @docker_host.user_id }
    end

    assert_redirected_to docker_host_path(assigns(:docker_host))
  end

  test "should show docker_host" do
    get :show, id: @docker_host
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @docker_host
    assert_response :success
  end

  test "should update docker_host" do
    patch :update, id: @docker_host, docker_host: { ssl_cert: @docker_host.ssl_cert, url: @docker_host.url, user_id: @docker_host.user_id }
    assert_redirected_to docker_host_path(assigns(:docker_host))
  end

  test "should destroy docker_host" do
    assert_difference('DockerHost.count', -1) do
      delete :destroy, id: @docker_host
    end

    assert_redirected_to docker_hosts_path
  end
end
