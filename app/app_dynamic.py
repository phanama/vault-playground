import psycopg2
import os
import sys
from flask import Flask
import hvac

app = Flask(__name__)
app_name = None
vault_addr = 'http://127.0.0.1:8200'
vault_client = hvac.Client(url=vault_addr)
vault_client.login('v1/auth/userpass/')

#try:
#    app_name = os.environ['APP_NAME']


def fetch_credentials(credential_path: str):
    pass