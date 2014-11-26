require 'openssl'

# Info for connecting to a physical or virtual machine running Docker.
class DockerHost < ActiveRecord::Base
  # The user that owns this host.
  belongs_to :user
  validates :user, presence: true

  # User-friendly name for the host.
  validates :name, presence: true, length: 1..128, uniqueness: { scope: :name }

  # The URL to the Docker daemon.
  validates :url, presence: true, length: 1..1.kilobyte

  # The PEM-encoded private key for the client certificate.
  validates :client_key_pem, length: { in: 1..8.kilobytes, allow_nil: true },
                             pem_key: { allow_nil: true }

  # The PEM-encoded TLS client certificate.
  validates :client_cert_pem, length: { in: 1..8.kilobytes, allow_nil: true },
                              pem_certificate: { allow_nil: true }

  # The PEM-encoded server CA certificate.
  validates :ca_cert_pem, length: { in: 1..8.kilobytes, allow_nil: true },
                          pem_certificate: { allow_nil: true }

  # The Docker daemon's response to the version API call.
  #
  # @return {Object} the daemon's response, or null if the API call failed
  def docker_version_object
    # TODO(pwnall): the cache doesn't cover the nil case
    @_docker_version_object ||= docker_version_object!
  end

  # Uncached version of {#docker_version_object}.
  def docker_version_object!
    begin
      Docker.version docker_connection
    rescue Excon::Errors::Error
      nil
    end
  end

  # A connection to the referenced Docker daemon.
  #
  # @return {Docker::Connection} a connection to the Docker daemon
  def docker_connection
    @_docker_connection ||= docker_connection!
  end

  # Uncached version of {#docker_connection}.
  def docker_connection!
    if client_key_pem
      cert_store = OpenSSL::X509::Store.new
      cert_store.add_cert OpenSSL::X509::Certificate.new ca_cert_pem
      options = {
        scheme: 'https',
        certificate: client_cert_pem,
        private_key: client_key_pem,
        ssl_cert_store: cert_store
      }
    else
      options = {}
    end
    Docker::Connection.new url, options
  end

  # Generates a random name for a host.
  #
  # The name isn't guaranteed to be unique.
  def self.random_name
    Faker::Address.street_address.downcase.tr ' ', '-'
  end
end
