import psycopg2
import os
import logging
from flask import Flask

app = Flask(__name__)

app_port = os.environ['APP_PORT']
app_name = os.environ['APP']
username = os.environ['POSTGRES_USERNAME']
password = os.environ['POSTGRES_PASSWORD']
hostname = os.environ['POSTGRES_HOSTNAME']
port = os.environ['POSTGRES_PORT']
database = os.environ['POSTGRES_DATABASE']

@app.route('/get_one_customer')
def get_one_customer() -> str:
    try:
        connection = psycopg2.connect(user = username,
                                    password = password,
                                    host = hostname,
                                    port = port,
                                    database = database)
        cursor = connection.cursor()
        cursor.execute("SELECT cust_name FROM CUSTOMERS LIMIT 1;")
        record = cursor.fetchone()
        return '{0}:{1} -> {2}'.format(app_name, app_port, record[0])
    except (Exception, psycopg2.Error) as error :
        logging.error("Error while connecting to PostgreSQL", error)
    finally:
            if(connection):
                cursor.close()
                connection.close()

@app.route("/")
def home():
    return "app1"
    
if __name__ == "__main__":
    app.run(debug=True, port=app_port)