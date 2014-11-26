require 'test_helper'

class DockerVersionTest < ActiveSupport::TestCase
  test 'read_from_host!' do
    DockerVersion.destroy_all

    version = DockerVersion.new host: docker_hosts(:local)
    version.read_from_host!
    assert version.valid?, version.errors.inspect
  end

  test 'read_from_host! with network error' do
    host = DockerHost.new name: 'test-host', url: 'tcp://0.0.0.0:2376'

    version = DockerVersion.new host: host
    version.read_from_host!
    assert_nil version.os
    assert_nil version.arch
    assert_nil version.docker
    assert_nil version.api
    assert_nil version.kernel
    assert_nil version.read_at
  end

  test 'up_to_date?' do
    host = DockerHost.new
    host.updated_at = Time.now -  6.hours
    version = DockerVersion.new host: host
    assert_equal false, version.up_to_date?

    version.read_at = host.updated_at
    assert_equal true, version.up_to_date?

    version.read_at = Time.now - 2.days
    assert_equal false, version.up_to_date?

    version.read_at = Time.now - 1.hour
    assert_equal true, version.up_to_date?

    host.updated_at = Time.now - 1.minute
    assert_equal false, version.up_to_date?
  end

  test 'ensure_updated' do
    DockerVersion.destroy_all
    host = docker_hosts(:local)

    version = DockerVersion.new host: host
    version.ensure_updated
    assert version.valid?, version.errors.inspect
    assert_equal true, version.up_to_date?
    assert_equal false, version.changed?
  end

  test 'ensure_updated with network error' do
    DockerVersion.destroy_all
    host = docker_hosts(:local)
    host.url = 'tcp://0.0.0.0:2376'

    version = DockerVersion.new host: host
    version.ensure_updated
    assert_equal false, version.up_to_date?
  end

  test 'ensure_updated when no update is necessary' do
    version = docker_versions(:local)
    assert version.up_to_date?, 'incorrect test setup'
    mocha.expects(:read_from_host!).never
    version.ensure_updated
  end
end
