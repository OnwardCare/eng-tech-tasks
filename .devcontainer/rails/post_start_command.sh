#!/bin/bash

source /usr/local/rvm/scripts/rvm
rvm use 3.4.7

# Write DB client config only if it doesn't exist yet.
# postStartCommand runs after VS Code and extensions initialize, so the
# DB client extension won't overwrite this file on subsequent starts.
if [ ! -f "$HOME/.dbclient/storage/config.jsonc" ]; then
  mkdir -p "$HOME/.dbclient/storage"
  cat > "$HOME/.dbclient/storage/config.jsonc" << 'EOF'
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
fi
