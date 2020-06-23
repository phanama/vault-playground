#Demonstrates using app config/secret without vault
import psycopg2
import os
import logging
from flask import Flask
import sys

app = Flask(__name__)
app_port = None
app_name = None
username = None
password = None
hostname = None
port = None
database = None

#bootstrap app config from OS env vars without fetching from vault
try:
    app_port = os.environ['APP_PORT']
    app_name = os.environ['APP_NAME']
    username = os.environ['POSTGRES_USERNAME']
    password = os.environ['POSTGRES_PASSWORD']
    hostname = os.environ['POSTGRES_HOSTNAME']
    port = os.environ['POSTGRES_PORT']
    database = os.environ['POSTGRES_DATABASE']
except (Exception, KeyError) as e:
    logging.error(e)
    sys.exit(1)


@app.route('/get_one_customer')
def get_one_customer() -> str:
    '''Fetch one customer from the database using the credentials set previously
       through OS env vars.
    '''
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
        return 'Error'
    finally:
        if(connection):
            cursor.close()
            connection.close()


@app.route("/")
def home():
    return app_name


if __name__ == "__main__":
    app.run(debug=True, port=app_port)
