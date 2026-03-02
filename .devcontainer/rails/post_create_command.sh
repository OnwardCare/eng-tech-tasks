#!/bin/bash

source /usr/local/rvm/scripts/rvm

PROJECT_NAME=$(basename "$(pwd)")

sudo chown -R vscode:vscode /workspaces/$PROJECT_NAME
sudo chmod +x /workspaces/$PROJECT_NAME/rails/trading/bin/*

cp .devcontainer/rails/.rubocop.yml rails/trading/.rubocop.yml

cd rails/trading
rails db:create
rails db:migrate
rails db:seed
