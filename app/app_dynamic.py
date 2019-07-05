import psycopg2
import os
import sys
import logging
from flask import Flask
import hvac

app = Flask(__name__)
app_name = None
try:
    app_name = os.environ['APP_NAME']
except Exception as e:
    logging.error(e)
vault_addr = 'http://127.0.0.1:8200'
vault_client = hvac.Client(url=vault_addr)
vault_client.auth_userpass(app_name, '{}vaultpassword'.format(app_name), mount_point='userpass')

def fetch_credentials(credential_path: str):
    pass