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
    assert_not_nil @host.errors[:client_key_pem]
  end

  test 'rejects invalid client certificates' do
    @host.client_cert_pem = "-----BEGIN CERTIFICATE-----\n"
    assert !@host.valid?
    assert_not_nil @host.errors[:client_cert_pem]
  end

  test 'rejects invalid CA certificates' do
    @host.ca_cert_pem = "-----BEGIN CERTIFICATE-----\n"
    assert !@host.valid?
    assert_not_nil @host.errors[:ca_cert_pem]
  end

  test 'docker_connection works for a valid connection' do
    connection = @host.docker_connection
    assert_kind_of Docker::Connection, connection

    version = Docker.version connection
    assert_operator version, :has_key?, 'Version'
  end

  test 'docker_version_object' do
    version_object = @host.docker_version_object
    assert_not_nil version_object['Version']
  end

  test 'docker_version_object is null for an invalid connection' do
    @host.url = 'tcp://0.0.0.0:2376'
    assert_nil @host.docker_version_object
  end

  test '#random_name' do
    names = (1..10).map { DockerHost.random_name }.uniq
    assert_equal 10, names.length
  end
end
