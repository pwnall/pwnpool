json.array!(@docker_hosts) do |docker_host|
  json.extract! docker_host, :name, :url, :ca_cert_pem, :client_cert_pem,
                             :client_key_pem
  json.url docker_host_url(docker_host, format: :json)
end
