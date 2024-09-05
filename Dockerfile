# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.3.1
FROM ruby:$RUBY_VERSION-alpine as base

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Install essential packages
RUN apk add --no-cache \
    bash \
    build-base \
    libvips \
    git \
    postgresql-dev \
    sqlite-dev \
    tzdata \
    curl \
    nodejs \
    yarn \
    pkgconfig

# Throw-away build stage to reduce size of the final image
FROM base as build

# Install additional packages needed to build gems
RUN apk add --no-cache build-base libvips-dev

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompile assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Final stage for the app image
FROM base

# Install minimal packages needed for deployment
RUN apk add --no-cache \
    libsqlite3 \
    libvips

# Copy built artifacts: gems and application code
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN adduser -D -h /home/rails -s /bin/bash rails && \
    chown -R rails:rails /rails/db /rails/log /rails/storage /rails/tmp
USER rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Expose the Rails server port
EXPOSE 3000

# Start the server by default, this can be overwritten at runtime
CMD ["./bin/rails", "server"]
