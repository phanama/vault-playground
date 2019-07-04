export VAULT_ADDR="http://127.0.0.1:8200"

#enable kv secrets
vault secrets enable -path=kv kv
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
vault write auth/userpass/users/almighty password=almightyvaultpassword policies=almighty

docker run -p 5432:5432 -e POSTGRES_PASSWORD=postgres --name postgres -v "$PWD":/tmp/postgres --restart=always -d postgres
sleep 5
docker exec postgres psql -U postgres -f /tmp/postgres/init.sql
docker exec postgres psql -U postgres -d app1database -f /tmp/postgres/create_app1.sql
docker exec postgres psql -U postgres -d app1database -f /tmp/postgres/populate_app1.sql
docker exec postgres psql -U postgres -d app2database -f /tmp/postgres/create_app2.sql
docker exec postgres psql -U postgres -d app2database -f /tmp/postgres/populate_app2.sql