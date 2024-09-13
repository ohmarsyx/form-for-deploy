# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.3.1
FROM ruby:$RUBY_VERSION-alpine AS builder

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    git \
    nodejs \
    vips-dev \
    tzdata

# Set working directory
WORKDIR /app

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3 --without development test \
    && rm -rf ~/.bundle/ /usr/local/bundle/cache/

# Copy application code
COPY . .

# Precompile bootsnap code and assets
RUN bundle exec bootsnap precompile --gemfile app/ lib/ \
    && SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

# Final stage
FROM ruby:$RUBY_VERSION-alpine

# Install runtime dependencies
RUN apk add --no-cache \
    vips \
    tzdata \
    gcompat

# Set working directory
WORKDIR /app

# Copy built artifacts from builder stage
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app

# Set Rails environment
ENV RAILS_ENV=production \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_LOG_TO_STDOUT=true

# Create and switch to a non-root user
RUN adduser -h /app -s /bin/sh -D rails \
    && chown -R rails:rails /app
USER rails:rails

# Expose port 3000
EXPOSE 3000

# Start the Rails server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]