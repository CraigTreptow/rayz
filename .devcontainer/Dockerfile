FROM ruby:3.4.1-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd --gid 1000 vscode \
    && useradd --uid 1000 --gid 1000 -m vscode

# Install common development gems
RUN gem install bundler solargraph rubocop

WORKDIR /workspaces/app
COPY Gemfile Gemfile.lock ./

USER vscode
