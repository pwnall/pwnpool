# Version information for a Docker server.
class DockerVersion < ActiveRecord::Base
  # The host of the Docker server whose version this is.
  belongs_to :host, class_name: 'DockerHost', inverse_of: :version_info
  validates :host, presence: true, uniqueness: true

  # The OS that the Docker server is running on.
  validates :os, presence: true, length: 1..32

  # The architecture that the Docker server is running on.
  validates :arch, presence: true, length: 1..32

  # The Docker software version that the server is running.
  validates :docker, presence: true, length: 1..32

  # The Docker API version that the server supports.
  validates :api, presence: true, length: 1..32

  # The OS kernel that the Docker server is running on.
  validates :kernel, presence: true, length: 1..32

  # Reads the version information from the Docker server.
  #
  # Use {#ensure_updated} insted of calling this directly.
  #
  # @return [Boolean] true if the version was read, false otherwise
  def read_from_host!
    begin
      version_object = Docker.version host.docker_connection
    rescue Excon::Errors::Error
      return false
    end

    self.read_at = Time.now
    self.os = version_object['Os']
    self.arch = version_object['Arch']
    self.docker = version_object['Version']
    self.api = version_object['ApiVersion']
    self.kernel = version_object['KernelVersion']
    true
  end

  # Updates the version information if it is out of date.
  def ensure_updated
    unless up_to_date?
      save! if read_from_host!
    end
  end

  # True if the cached version information is reasonably up to date.
  def up_to_date?
    return false if read_at.nil?
    # NOTE: this catches the case where the user edits the DockerHost info
    return false if host.updated_at > read_at
    (Time.now - read_at) < 1.day
  end
end
