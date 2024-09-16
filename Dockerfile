# Base image with specified Ruby version
ARG RUBY_VERSION=3.3.1
FROM ruby:$RUBY_VERSION-alpine AS base

# Set production environment variables
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    SECRET_KEY_BASE_DUMMY="1"

# Common packages needed in all stages
RUN apk add --no-cache \
    vips-dev \
    tzdata \
    bash \
    gcompat

# Set the app's working directory
WORKDIR /rails


# Build stage for assets and dependencies
FROM base as build

# Install build dependencies
RUN apk add --no-cache --virtual .build-deps \
    build-base \
    git \
    nodejs

# Copy Gemfiles and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3 --without development test && \
    rm -rf /usr/local/bundle/cache

# Precompile bootsnap code
RUN bundle exec bootsnap precompile --gemfile

# Copy application code and precompile assets
COPY . . 
RUN ./bin/rails assets:precompile

# Clean up build dependencies to reduce final image size
RUN apk del .build-deps


# Final stage
FROM base

# Copy the precompiled gems and application code from the build stage
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Ensure proper permissions
RUN adduser -h /rails -s /bin/sh -D rails && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# Expose default Rails port
EXPOSE 3000

# Default command to run the server
CMD ["./bin/rails", "db:prepare", "&&", "./bin/rails", "server", "-b", "0.0.0.0"]
