require 'test_helper'

class DockerHostTest < ActiveSupport::TestCase
  setup do
    @host = DockerHost.new user: users(:john), name: 'test-host',
      url: ENV['DOCKER_URL'] || ENV['DOCKER_HOST']

    if ENV['DOCKER_CERT_PATH']
      @host.ca_cert_pem = File.read File.join(ENV['DOCKER_CERT_PATH'], 'ca.pem')
      @host.client_cert_pem = File.read File.join(ENV['DOCKER_CERT_PATH'], 'cert.pem')
      @host.client_key_pem = File.read File.join(ENV['DOCKER_CERT_PATH'], 'key.pem')
    end
  end

  test 'setup' do
    assert @host.valid?, @host.errors.inspect
  end

  test 'rejects invalid client keys' do
    @host.client_key_pem = "-----BEGIN RSA PRIVATE KEY-----\n"
    assert !@host.valid?
    assert_not_empty @host.errors[:client_key_pem]
  end

  test 'accepts empty client keys' do
    @host.client_key_pem = ''
    assert_equal nil, @host.client_key_pem
    assert @host.valid?, @host.errors.inspect
  end

  test 'rejects invalid client certificates' do
    @host.client_cert_pem = "-----BEGIN CERTIFICATE-----\n"
    assert !@host.valid?
    assert_not_empty @host.errors[:client_cert_pem]
  end

  test 'accepts empty client certificates' do
    @host.client_cert_pem = ''
    assert_equal nil, @host.client_cert_pem
    assert @host.valid?, @host.errors.inspect
  end

  test 'rejects invalid CA certificates' do
    @host.ca_cert_pem = "-----BEGIN CERTIFICATE-----\n"
    assert !@host.valid?
    assert_not_empty @host.errors[:ca_cert_pem]
  end

  test 'accepts empty CA certificates' do
    @host.ca_cert_pem = ''
    assert_equal nil, @host.ca_cert_pem
    assert @host.valid?, @host.errors.inspect
  end

  test 'rejects duplicate names' do
    @host.name = docker_hosts(:local).name
    @host.user = docker_hosts(:local).user
    assert !@host.valid?
    assert_not_empty @host.errors[:name]
  end

  test 'rejects names with periods' do
    @host.name = 'a.b'
    assert !@host.valid?
    assert_not_empty @host.errors[:name]
  end

  test 'docker_connection works for a valid connection' do
    connection = @host.docker_connection
    assert_kind_of Docker::Connection, connection

    version = Docker.version connection
    assert_operator version, :has_key?, 'Version'
  end

  test 'ensure_version_info_updated for new host' do
    @host.save!
    @host.ensure_version_info_updated
    assert @host.version_info.up_to_date?
  end

  test 'ensure_version_info_updated for existing host' do
    host = docker_hosts(:local)
    host.version_info.read_at = Time.now - 2.days
    assert !host.version_info.up_to_date?, 'test setup error'
    host.ensure_version_info_updated
    assert host.version_info.up_to_date?
  end

  test '.random_name' do
    names = (1..10).map { DockerHost.random_name }.uniq
    assert_equal 10, names.length
  end

  test 'to_param' do
    assert_equal 'test-host', @host.to_param
  end

  test 'with_user_and_name' do
    assert_equal docker_hosts(:local), DockerHost.with_user_and_name(
        docker_hosts(:local).user, docker_hosts(:local).name).first
  end
end
