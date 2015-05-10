require 'test_helper'

class DockerImageTest < ActiveSupport::TestCase
  setup do
    @host = docker_hosts(:local)
    @connection = @host.docker_connection

    busybox_image = nil
    loop do
      docker_images = Docker::Image.all({}, @connection)
      busybox_image = docker_images.find do |image|
        image.info['RepoTags'].include? 'busybox:latest'
      end
      break unless busybox_image.nil?
      Docker::Image.create({ fromImage: 'busybox', repo: 'busybox',
          tag: 'latest', registry: 'registry.hub.docker.com' }, nil,
          @connection)
    end

    @busybox_uid = busybox_image.info['id']
  end

  test 'read_docker_object' do
    @host.images.destroy_all
    docker_objects = Docker::Image.all({}, @connection)

    image = DockerImage.new host: @host
    assert_operator docker_objects.length, :>=, 1, 'test setup error'
    image.read_docker_object docker_objects.first
    image.read_at = Time.now
    assert image.valid?, image.errors.inspect
  end

  test '.read_all_from_host! creates DockerImage rows in the database' do
    @host.images.destroy_all
    assert_equal true, DockerImage.read_all_from_host!(@host)

    assert_operator @host.images(true).length, :>=, 1, 'no image created'
    assert @host.images.any? { |image| image.docker_uid = @busybox_uid }
  end

  test '.read_all_from_host! with network error' do
    host = DockerHost.create user: @host.user, name: 'invalid-host',
                             url: 'tcp://0.0.0.0:2376'
    assert_equal false, DockerImage.read_all_from_host!(host)

    assert_equal 0, host.images.length
  end

  test '.read_all_from_host! destroys removed images' do
    old_image = DockerImage.create! host: @host, docker_uid: 'invalid0000',
        docker_parent_uid: 'also0000invalid', size: 1337, virtual_size: 1337,
        read_at: Time.now

    assert_equal true, DockerImage.read_all_from_host!(@host)
    assert_equal nil, DockerImage.where(id: old_image.id).first
    assert_not_includes @host.images(true).map(&:docker_uid), 'invalid0000'
  end

  test '.read_all_from_host! updates existing images' do
    assert_equal true, DockerImage.read_all_from_host!(@host)

    # NOTE: the fixture DockerImage instances will most likely be deleted, so
    #       we need to reload the images collection
    image = @host.images(true).first
    # NOTE: simulating outdated information
    image.update_attributes! docker_parent_uid: 'invalid0000',
                             read_at: Time.now - 1.day

    assert_equal true, DockerImage.read_all_from_host!(@host)
    image.reload
    assert_not_equal 'invalid0000', image.docker_parent_uid
    assert_operator image.read_at, :>, Time.now - 1.hour
  end
end
