#!/bin/bash

source /usr/local/rvm/scripts/rvm

PROJECT_NAME=$(basename "$(pwd)")

sudo chown -R vscode:vscode /workspaces/$PROJECT_NAME
sudo chmod +x /workspaces/$PROJECT_NAME/rails/trading/bin/*

mkdir -p $HOME/.dbclient/storage
cat > $HOME/.dbclient/storage/config.jsonc << 'EOF'
// This file is a temporary file, the configuration is not actually stored here.
{
  "database": {
    "1000000000000": {
      "host": "127.0.0.1",
      "port": 3306,
      "dbType": "SQLite",
      "name": "Development",
      "advance": {
        "idleConfig": {
          "enable": true
        },
        "hideSystemSchema": true,
        "groupingTables": false,
        "loadMetaDataWhenExpandTreeView": true
      },
      "treeFeatures": [],
      "usingSSH": false,
      "useSocksProxy": false,
      "useHTTPProxy": false,
      "global": true,
      "savePassword": "Forever",
      "readonly": false,
      "sort": 1,
      "useSSL": false,
      "dbPath": "/workspaces/eng-tech-tasks/rails/trading/db/development.sqlite3",
      "fs": {
        "encoding": "utf8",
        "showHidden": true
      },
      "key": "1000000000000",
      "connectionKey": "database.connections"
    },
    "1000000000001": {
      "host": "127.0.0.1",
      "port": 3306,
      "dbType": "SQLite",
      "name": "Test",
      "advance": {
        "idleConfig": {
          "enable": true
        },
        "hideSystemSchema": true,
        "groupingTables": false,
        "loadMetaDataWhenExpandTreeView": true
      },
      "treeFeatures": [],
      "usingSSH": false,
      "useSocksProxy": false,
      "useHTTPProxy": false,
      "global": true,
      "savePassword": "Forever",
      "readonly": false,
      "sort": 2,
      "useSSL": false,
      "dbPath": "/workspaces/eng-tech-tasks/rails/trading/db/test.sqlite3",
      "fs": {
        "encoding": "utf8",
        "showHidden": true
      },
      "key": "1000000000001",
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
