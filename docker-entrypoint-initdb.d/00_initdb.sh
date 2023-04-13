#!/bin/bash
echo 'Creating datastore database and user...'
set -e
psql -d "$POSTGRES_DB" -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" <<-EOSQL
	    CREATE USER $DATASTORE_USER WITH PASSWORD '$DATASTORE_USER_PASSWORD';
	    CREATE DATABASE $POSTGRES_DATABASE_DATASTORE;
EOSQL
echo 'Datastore database and user created'
