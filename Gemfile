source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '>= 4.2.0.beta4'

# Arel 6.0.0 has a breaking API change that breaks rails 4.2.0.beta4.
# TODO(pwnall): remove this when a newer Rails gets released.
gem 'arel', '6.0.0.beta2'

# Use PostgreSQL as the database for Active Record
gem 'pg', '>= 0.17.1'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.0.beta1'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 2.5.3'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jQuery as the JavaScript library
gem 'jquery-rails', '~> 4.0.0.beta2'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.2'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use Unicorn as the app server
gem 'unicorn'

# Authentication.
gem 'authpwn_rails', '>= 0.17.1'
gem 'omniauth-twitter', '>= 1.0.1'
gem 'omniauth-google-oauth2', '>= 0.2.6'
gem 'omniauth-github', '>= 0.2.6'

# CSS assets.
gem 'foundation-rails', '>= 5.4.5.0'
gem 'font-awesome-rails', '>= 4.2.0.0'

# Sass 3.4.6 fails hard at foundation.
gem 'sass', '~> 3.2.19'

# Docker API client.
gem 'docker-api', '>= 1.15', require: 'docker'
# TODO(pwnall): remove the GH branch reference when the relevant PR is merged
#               https://github.com/excon/excon/pull/444
gem 'excon', '>= 0.41.0', github: 'pwnall/excon', branch: 'cert_store'

# Host name generation.
gem 'faker', '>= 1.4.3'

# Pagination.
gem 'kaminari', '>= 0.16.1'

# Base32 URLs. (speculative)
gem 'base32', '>= 0.3.2'

# Image download. (speculative)
gem 'rubyzip', '>= 1.1.6', require: 'zip'

group :development, :test do
  # Use MySQL in dev, because we can db:drop without a server restart.
  gem 'mysql2', '>= 0.3.17'

  # Fancy error pages.
  gem 'better_errors'
  gem 'binding_of_caller'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

