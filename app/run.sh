#!/usr/bin/env bash

set -eu

export VAULT_ADDR=http://127.0.0.1:8200
export APP_NAME="$1"
export APP_PORT="$2"
DYNAMIC=$3


if [ -z "$DYNAMIC" ]; then
    VAULT_PASSWORD="${APP_NAME}vaultpassword"

    #VAULT_TOKEN=$(curl --silent -XPOST http://$VAULT_ADDRESS/v1/auth/userpass/login/$APP_NAME/ -d '{"password": "'$VAULT_PASSWORD'"}' | jq -r '.auth.client_token') 

    vault login -method=userpass username="$APP_NAME" password="${VAULT_PASSWORD}" > /dev/null

    SECRET=$(vault read -format=json kv/$APP_NAME/postgres)

    export POSTGRES_USERNAME=$(echo $SECRET | jq -r '.data.username')
    export POSTGRES_PASSWORD=$(echo $SECRET | jq -r '.data.password')
    export POSTGRES_HOSTNAME=$(echo $SECRET | jq -r '.data.hostname')
    export POSTGRES_PORT=$(echo $SECRET | jq -r '.data.port')
    export POSTGRES_DATABASE=$(echo $SECRET | jq -r '.data.database')
    python3 app.py
else
    python3 app_dynamic.py
fi