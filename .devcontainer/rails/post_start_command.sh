#!/bin/bash

source /usr/local/rvm/scripts/rvm
rvm use 3.4.7

echo "post_start_command: running as $(whoami), HOME=$HOME"
echo "post_start_command: storage dir contents before write:"
ls -la "$HOME/.dbclient/storage/" 2>&1

# Sleep to give the DB extension time to finish initializing its storage dir
sleep 5

mkdir -p "$HOME/.dbclient/storage"
echo "post_start_command: writing DB client config..."
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
echo "post_start_command: done. Storage contents:"
ls -la "$HOME/.dbclient/storage/"
