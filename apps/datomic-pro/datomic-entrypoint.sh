#!/usr/bin/env bash
set -eo pipefail

if [ "$(id -u)" = "0" ]; then
    echo "WARNING: Running Datomic as root is not recommended. Please run as a non-root user."
    echo "         This can be ignored if you are using rootless mode."
fi

if [ "$1" = "console" ]; then
  if [ -n "$DB_URI_FILE" ] && [ -f "$DB_URI_FILE" ]; then
        DB_URI=$(cat "$DB_URI_FILE")
  fi
  ./bin/console -p 8080 dev "$DB_URI"
else
    /generate-properties.clj
    ./bin/transactor "${DATOMIC_TRANSACTOR_PROPERTIES_PATH}"
fi
