require 'test_helper'

class DockerImageTest < ActiveSupport::TestCase
  setup do
    # TODO(pwnall): create an image to prime the tests
  end

  test 'read_docker_object' do
    host = docker_hosts(:local)
    host.images.destroy_all
    docker_objects = Docker::Image.all({}, host.docker_connection)

    image = DockerImage.new host: host
    assert_operator docker_objects.length, :>=, 1, 'test setup error'
    image.read_docker_object docker_objects.first
    image.read_at = Time.now
    assert image.valid?, image.errors.inspect
  end

  test '.read_all_from_host! creates images' do
    host = docker_hosts(:local)
    host.images.destroy_all
    assert_equal true, DockerImage.read_all_from_host!(host)

    assert_operator host.images(true).length, :>=, 1, 'no image created'
  end

  test '.read_all_from_host! with network error' do
    host = docker_hosts(:local)
    host.url = 'tcp://0.0.0.0:2376'
    host.images.destroy_all
    assert_equal false, DockerImage.read_all_from_host!(host)

    assert_equal 0, host.images(true).length
  end

  test '.read_all_from_host! destroys removed images' do
    host = docker_hosts(:local)
    old_image = DockerImage.create! host: host, docker_uid: 'invalid0000',
        docker_parent_uid: 'also0000invalid', size: 1337, virtual_size: 1337,
        read_at: Time.now

    assert_equal true, DockerImage.read_all_from_host!(host)
    assert_equal nil, DockerImage.where(id: old_image.id).first
  end

  test '.read_all_from_host! updates existing images' do
    host = docker_hosts(:local)
    assert_equal true, DockerImage.read_all_from_host!(host)

    image = host.images.first
    # NOTE: simulating outdated information
    image.update_attributes! docker_parent_uid: 'invalid0000',
                             read_at: Time.now - 1.day

    assert_equal true, DockerImage.read_all_from_host!(host)
    image.reload
    assert_not_equal 'invalid0000', image.docker_parent_uid
    assert_operator image.read_at, :>, Time.now - 1.hour
  end
end
