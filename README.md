# HashiCorp's Vault Feature Demonstration

This is a simple app demonstrating [HashiCorp's Vault](https://www.vaultproject.io/docs/) usage. There are two use cases in this page:
- Using Vault's [KV/2 Secrets Engine](https://www.vaultproject.io/docs/secrets/kv/kv-v2.html) to store static secrets
- Using Vault's [Database Engine for PostgreSQL](https://www.vaultproject.io/docs/secrets/databases/postgresql.html) to generate dynamic credentials

Requirements:
- python3
- python3-pip
- Python virtualenv
- Vault
- docker & docker-engine

To setup and run the app:
- Setup virtualenv `virtualenv venv && source ./venv/bin/activate`
- Install requirements `pip install -r requirements.txt`
- Run vault in another terminal `vault server -dev`
- Setup vault data, roles, and policies, and setup postgres with data `./setup.sh`
- Run the app. `./app/run.sh APP_NAME APP_PORT IS_DYNAMIC` E.g. `./app/run.sh app1 5001 false`

There are three apps to demonstrate the use cases above:
- app1 and app2 demonstrate Vault KV/2 Secrets Engine. Pass it to `APP_NAME` with `IS_DYNAMIC` set to `false`
  - It uses the `./run.sh` script to fetch secrets and set to ENV variables. These apps will then use the secrets stored in those ENV variables
- app3 demonstrates Vault Dynamic Postgres credentials.
  - It uses [`hvac`](https://github.com/hvac/hvac), Vault python client to fetch secrets directly to Vault.

Access the apps with curl:
- `curl http://127.0.0.1:APP_PORT`
