require 'openssl'

# Info for connecting to a physical or virtual machine running Docker.
class DockerHost < ActiveRecord::Base
  # The user that owns this host.
  belongs_to :user, inverse_of: :docker_hosts
  validates :user, presence: true

  # User-friendly name for the host.
  validates :name, presence: true, length: 1..128,
      uniqueness: { scope: :name }, format: /\A[A-Za-z0-9\-_]+\Z/

  # The URL to the Docker daemon.
  validates :url, presence: true, length: 1..1.kilobyte

  # The PEM-encoded private key for the client certificate.
  validates :client_key_pem, length: { in: 1..8.kilobytes, allow_nil: true },
                             pem_key: { allow_nil: true }
  # Turn empty values into nil.
  def client_key_pem=(new_client_key_pem)
    if new_client_key_pem.blank?
      super nil
    else
      super new_client_key_pem
    end
  end

  # The PEM-encoded TLS client certificate.
  validates :client_cert_pem, length: { in: 1..8.kilobytes, allow_nil: true },
                              pem_certificate: { allow_nil: true }
  # Turn empty values into nil.
  def client_cert_pem=(new_client_cert_pem)
    if new_client_cert_pem.blank?
      super nil
    else
      super new_client_cert_pem
    end
  end

  # The PEM-encoded server CA certificate.
  validates :ca_cert_pem, length: { in: 1..8.kilobytes, allow_nil: true },
                          pem_certificate: { allow_nil: true }
  # Turn empty values into nil.
  def ca_cert_pem=(new_ca_cert_pem)
    if new_ca_cert_pem.blank?
      super nil
    else
      super new_ca_cert_pem
    end
  end

  # Cached version information for the Docker daemon.
  has_one :version_info, dependent: :destroy, class_name: 'DockerVersion',
      foreign_key: :host_id, inverse_of: :host

  # Images stored on this Docker daemon's host.
  has_many :images, dependent: :destroy, class_name: 'DockerImage',
      foreign_key: :host_id, inverse_of: :host

  # Updates the cached version information.
  def ensure_version_info_updated
    build_version_info unless version_info
    version_info.ensure_updated
  end

  # True if this connection information includes TLS key material.
  def uses_tls?
    !client_key_pem.nil?
  end

  # A connection to the referenced Docker daemon.
  #
  # @return {Docker::Connection} a connection to the Docker daemon
  def docker_connection
    @_docker_connection ||= docker_connection!
  end

  # Uncached version of {#docker_connection}.
  def docker_connection!
    if uses_tls?
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

  # Use the name as a URL identifier.
  def to_param
    name
  end
  scope :with_user_and_name, -> (user, name) { where user: user, name: name }
end
