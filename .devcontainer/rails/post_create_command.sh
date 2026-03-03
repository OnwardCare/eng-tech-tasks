#!/bin/bash

source /usr/local/rvm/scripts/rvm
rvm use 3.4.7 --default

PROJECT_NAME=$(basename "$(pwd)")

sudo chown -R vscode:vscode /workspaces/$PROJECT_NAME
sudo chmod +x /workspaces/$PROJECT_NAME/rails/trading/bin/*

cd rails/trading
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed

npm install -g sqlite3@5.1.7
