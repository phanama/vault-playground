import psycopg2
import os
import logging

username = os.environ['POSTGRES_USERNAME']
password = os.environ['POSTGRES_PASSWORD']
hostname = os.environ['POSTGRES_HOSTNAME']
port = os.environ['POSTGRES_PORT']
database = os.environ['POSTGRES_DATABASE']
database = 'app1database'

try:
    connection = psycopg2.connect(user = username,
                                  password = password,
                                  host = hostname,
                                  port = port,
                                  database = database)
    cursor = connection.cursor()
    cursor.execute("SELECT * FROM CUSTOMERS;")
    record = cursor.fetchone()
    print(record)
except (Exception, psycopg2.Error) as error :
    logging.error("Error while connecting to PostgreSQL", error)
finally:
        if(connection):
            cursor.close()
            connection.close()