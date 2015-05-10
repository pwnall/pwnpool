# Information about an image on a Docker server.
class DockerImage < ActiveRecord::Base
  # The host of the Docker server that has this image.
  belongs_to :host, class_name: 'DockerHost', inverse_of: :images
  validates :host, presence: true

  # The Docker-assigned ID for this image.
  validates :docker_uid, presence: true, length: 1..64,
                         format: /\A[a-z0-9]+\Z/, uniqueness: { scope: :host }

  # The Docker-assigned ID for this image's parent.
  validates :docker_parent_uid, length: { in: 1..64, allow_nil: true },
      format: { with: /\A[a-z0-9]+\Z/, allow_nil: true }
  def docker_parent_uid=(new_parent_uid)
    if new_parent_uid.blank?
      super nil
    else
      super new_parent_uid
    end
  end

  # The size this image takes up on disk.
  validates :size, presence: true,
      numericality: { greater_than_or_equal_to: 0, integer_only: true }

  # The size of the filesystem inside this image.
  validates :virtual_size, presence: true,
      numericality: { greater_than_or_equal_to: 0, integer_only: true }

  # The time when the image metadata was read from docker.
  validates :read_at, presence: true

  # Use the docker image ID in the URLs.
  def to_param
    docker_uid
  end
  scope :with_user_host_name_and_docker_uid, -> (user, host_name, docker_uid) {
    joins(:host).where(docker_hosts: { user_id: user.id },
                       docker_uid: docker_uid).includes(:host)
  }

  # Updates the image's fields with the response in a Docker::Image object.
  #
  # @param {Docker::Image} docker_object an object that contains metadata about
  #   this image
  def read_docker_object(docker_object)
    image_info = docker_object.info
    self.docker_uid = image_info['id']
    self.docker_parent_uid = image_info['ParentId']
    self.size = image_info['Size']
    self.virtual_size = image_info['VirtualSize']
    self.created_at = Time.at image_info['Created']
  end

  # Updates the images associated with a DockerHost.
  #
  # This creates, updates, and destroys DockerImage records, as necessary.
  #
  # @param {DockerHost} docker_host the host whose image information is updated
  # @return {Boolean} true if the DockerImage records were updated, false if
  #   the image information could not be read from the Docker server
  def self.read_all_from_host!(docker_host)
    old_images = docker_host.images.index_by(&:docker_uid)

    begin
      docker_objects = Docker::Image.all({ all: true, digests: true },
                                         docker_host.docker_connection)
    rescue Excon::Errors::Error
      return false
    end
    read_at = Time.now

    docker_objects.each do |docker_object|
      image_uid = docker_object.info['id']

      if old_image = old_images[image_uid]
        old_image.read_docker_object docker_object
        if old_image.changed?
          old_image.read_at = read_at
          old_image.save!
        end
        old_images.delete image_uid
      else
        image = docker_host.images.build read_at: read_at
        image.read_docker_object docker_object
        image.save!
      end
    end

    old_images.each { |_, old_image| old_image.destroy }
    true
  end
end
