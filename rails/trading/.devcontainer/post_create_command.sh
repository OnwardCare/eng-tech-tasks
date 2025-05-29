#!/bin/bash

PROJECT_NAME=$(basename "$(cd .. && pwd)")

sudo chown -R vscode:vscode /workspaces/$PROJECT_NAME
sudo chmod +x /workspaces/$PROJECT_NAME/bin/*

mkdir -p config
cp .devcontainer/rails.rb config/rails.rb
cp .devcontainer/.solargraph.yml .solargraph.yml
cp .devcontainer/.rubocop.yml .rubocop.yml

rails db:create
rails db:migrate
rails db:seed
