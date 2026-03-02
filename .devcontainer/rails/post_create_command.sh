#!/bin/bash

source /usr/local/rvm/scripts/rvm

PROJECT_NAME=$(basename "$(pwd)")

sudo chown -R vscode:vscode /workspaces/$PROJECT_NAME
sudo chmod +x /workspaces/$PROJECT_NAME/rails/trading/bin/*

mkdir -p $HOME/.dbclient/storage
cat > $HOME/.dbclient/storage/config.jsonc << 'EOF'
{
  "database": {
    "1000000000000": {
      "key": "1000000000000",
      "isTreeNode": true,
      "dbType": "SQLite",
      "database": "/workspaces/eng-tech-tasks/rails/trading/db/development.sqlite3",
      "name": "Development",
      "global": true,
      "savePassword": "Forever",
      "readonly": false,
      "sort": 1,
      "connectionKey": "database.connections"
    }
  },
  "nosql": null,
  "$schema": "https://cdn.database-client.com/dbclient/schema.json"
}
EOF

cd rails/trading
rails db:create
rails db:migrate
rails db:seed
