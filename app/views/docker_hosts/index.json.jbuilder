json.array!(@docker_hosts) do |docker_host|
  json.extract! docker_host, :id, :user_id, :url, :ssl_cert
  json.url docker_host_url(docker_host, format: :json)
end
