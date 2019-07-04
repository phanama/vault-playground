CREATE TABLE Customers
(
  cust_id      char(10)  NOT NULL ,
  cust_name    char(50)  NOT NULL
);

ALTER TABLE Customers ADD PRIMARY KEY (cust_id);

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO almighty;