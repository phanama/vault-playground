import psycopg2
import os
import sys
import logging
from flask import Flask
import hvac
import json

app = Flask(__name__)
app_name = None
app_port = None
try:
    app_name = os.environ['APP_NAME']
    app_port = os.environ['APP_PORT']
except Exception as e:
    logging.error(e)
vault_addr = 'http://127.0.0.1:8200'
#bootstrap the vault client
vault_client = hvac.Client(url=vault_addr)
vault_client.auth_userpass(app_name, '{}vaultpassword'.format(
    app_name), mount_point='userpass')


def fetch_credentials(app_name: str):
    '''Fetch credentials from vault server
    '''
    return vault_client.secrets.database.generate_credentials(
        mount_point='database',
        name=app_name
    )


hostname = '127.0.0.1'
port = 5432
database = 'app3database'

#fetch the credentials for postgres from the vault server
postgres_credentials = None
try:
    postgres_credentials = fetch_credentials(app_name)
except Exception as e:
    logging.error(e)
username = postgres_credentials['data']['username']
password = postgres_credentials['data']['password']


@app.route('/get_one_customer')
def get_one_customer() -> str:
    '''Get one customer from the database
       Demonstrates static pre-fetched credentials being used.
    '''
    connection = None
    try:
        connection = psycopg2.connect(user=username,
                                      password=password,
                                      host=hostname,
                                      port=port,
                                      database=database)
        cursor = connection.cursor()
        cursor.execute("SELECT cust_name FROM CUSTOMERS LIMIT 1;")
        record = cursor.fetchone()
        return '{0}:{1} -> {2}'.format(app_name, app_port, record[0])
    except (Exception, psycopg2.Error) as error:
        logging.error("Error while connecting to PostgreSQL", error)
        return 'Error: {}'.format(error)
    finally:
        if(connection):
            cursor.close()
            connection.close()


@app.route("/")
def home():
    return app_name


if __name__ == "__main__":
    app.run(debug=True, port=app_port)
