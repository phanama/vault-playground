CREATE DATABASE app1database;
CREATE ROLE app1 WITH PASSWORD 'app1postgrespassword' LOGIN;

CREATE DATABASE app2database;
CREATE ROLE app2 WITH PASSWORD 'app2postgrespassword' LOGIN;

CREATE DATABASE app3database;

CREATE ROLE almighty WITH LOGIN PASSWORD 'almightypostgrespassword';