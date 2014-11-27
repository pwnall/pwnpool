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

If using `boot2docker`, start the docker VM, and use `shellinit` to set up the
environment variables.

```bash
boot2docker start

$(boot2docker shellinit)
```
