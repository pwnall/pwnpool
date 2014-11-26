#  PwnPool

This is an attempt at managing Docker containers.

## Development Setup

Doing any development work requires a working [Docker](https://www.docker.com/)
installation. [boot2docker](http://boot2docker.io/) is a great way to get
Docker on Mac OS X or Windows.

The standard Rails application setup applies.

```bash
bundle install
rake db:create db:migrate
```

### Running Tests

The tests require `DOCKER_` environment variables pointing to a valid server.

If using `boot2docker`, start it, and run the `export` commands that it
outputs.

```bash
boot2docker start

# Don't copy-paste the commands below.
# Use the output from your invocation of boot2docker start.

export DOCKER_HOST=tcp://192.168.59.103:2376
export DOCKER_CERT_PATH=/Users/pwnall/.boot2docker/certs/boot2docker-vm
export DOCKER_TLS_VERIFY=1
```
