#!/bin/bash

source /usr/local/rvm/scripts/rvm

PROJECT_NAME=$(basename "$(pwd)")

sudo chown -R vscode:vscode /workspaces/$PROJECT_NAME
sudo chmod +x /workspaces/$PROJECT_NAME/bin/*

cp .devcontainer/rails/.rubocop.yml .rubocop.yml

rails db:create
rails db:migrate
rails db:seed
