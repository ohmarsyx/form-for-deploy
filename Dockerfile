# syntax = docker/dockerfile:1

ARG RUBY_VERSION=3.3.1
FROM ruby:$RUBY_VERSION-alpine AS builder

# Install build dependencies and set up environment
RUN apk add --no-cache build-base git nodejs vips-dev tzdata gcompat && \
    mkdir /rails && \
    gem install bundler

WORKDIR /rails

# Set Rails environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3 --without development test && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy application code and precompile assets
COPY . .
RUN bundle exec bootsnap precompile --gemfile app/ lib/ && \
    SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

# Final stage
FROM ruby:$RUBY_VERSION-alpine

# Install runtime dependencies
RUN apk add --no-cache vips tzdata gcompat bash && \
    adduser -h /rails -s /bin/bash -D rails

# Copy built artifacts from builder stage
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder --chown=rails:rails /rails /rails

# Set up environment and user
ENV RAILS_ENV="production" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    RAILS_SERVE_STATIC_FILES="true" \
    RAILS_LOG_TO_STDOUT="true"

USER rails:rails
WORKDIR /rails

# Expose port and start the server
EXPOSE 3000
CMD ["/bin/bash", "-c", "bundle exec rails db:prepare && bundle exec rails server -b 0.0.0.0"]