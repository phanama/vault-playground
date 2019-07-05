export VAULT_ADDR="http://127.0.0.1:8200"

#enable kv secrets
vault secrets enable -path=kv -version=2 kv
#enable userpass auth -> not for production
vault auth enable -path=userpass userpass

#write database passwords to vault
vault write kv/app1/postgres username=app1 password=app1postgrespassword hostname=127.0.0.1 port=5432 database=app1database
vault write kv/app2/postgres username=app2 password=app2postgrespassword hostname=127.0.0.1 port=5432 database=app2database
vault write kv/almighty/postgres username=postgres password=postgres hostname=127.0.0.1 port=5432

#create policies from documents
for policy in vault/policies/*; do
    policy_name="$(basename $policy | cut -f 1 -d '.')"
    vault policy write "$policy_name" $policy
done

#create users and map users to policies
vault write auth/userpass/users/app1 password=app1vaultpassword policies=app1
vault write auth/userpass/users/app2 password=app2vaultpassword policies=app2
vault write auth/userpass/users/app3 password=app3vaultpassword policies=app3
vault write auth/userpass/users/almighty password=almightyvaultpassword policies=almighty

openssl genrsa -out rootCA.key 4096
openssl req -x509 -new -nodes -key rootCA.key -subj "/CN=localhost" -sha256 -days 1024 -out rootCA.crt
openssl genrsa -out server.key 2048
openssl req -new -sha256 -key server.key -subj "/CN=localhost" -out server.req
openssl x509 -req -in server.req -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out server.crt -days 500 -sha256
chmod 0600 server.key

docker run -p 5432:5432 -e POSTGRES_PASSWORD=postgres --name postgres -v "$PWD":/tmp/postgres --restart=always -d \
    -v $PWD/server.crt:/var/lib/postgresql/server.crt:ro \
    -v $PWD/server.key:/var/lib/postgresql/server.key:ro \
    postgres -c ssl=on -c ssl_cert_file=/var/lib/postgresql/server.crt -c ssl_key_file=/var/lib/postgresql/server.key
sleep 5
docker exec postgres psql -U postgres -f /tmp/postgres/init.sql
docker exec postgres psql -U postgres -d app1database -f /tmp/postgres/create_app1.sql
docker exec postgres psql -U postgres -d app1database -f /tmp/postgres/populate_app1.sql
docker exec postgres psql -U postgres -d app2database -f /tmp/postgres/create_app2.sql
docker exec postgres psql -U postgres -d app2database -f /tmp/postgres/populate_app2.sql
docker exec postgres psql -U postgres -d app3database -f /tmp/postgres/create_app3.sql
docker exec postgres psql -U postgres -d app3database -f /tmp/postgres/populate_app3.sql

#vault dynamic postgres credentials
vault secrets enable database

#create app roles
vault write database/config/app3database \
    plugin_name=postgresql-database-plugin \
    allowed_roles="app3" \
    connection_url="postgresql://{{username}}:{{password}}@localhost:5432/" \
    verify_connection=false \
    username="postgres" \
    password="postgres"

vault write database/roles/app3 \
    db_name="app3database" \
    creation_statements="CREATE ROLE \"{{name}}\" WITH SUPERUSER LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';"
    default_ttl="10s" \
    max_ttl="30s"

vault audit enable file file_path=vault_audit.log