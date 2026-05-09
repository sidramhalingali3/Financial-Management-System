
CREATE DATABASE IF NOT EXISTS finance_db;

USE finance_db;

CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50),
    password VARCHAR(50),
    role VARCHAR(20)
);

INSERT INTO users(username,password,role)
SELECT 'Sidram Halingali','SidramHalingali123','Admin'
WHERE NOT EXISTS (
    SELECT * FROM users WHERE username='Sidram Halingali' AND role='Admin'
);

INSERT INTO users(username,password,role)
SELECT 'coll1','coll123','Collector'
WHERE NOT EXISTS (
    SELECT * FROM users WHERE username='coll1'
);

CREATE TABLE IF NOT EXISTS finance (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50),
    type VARCHAR(20),
    amount DOUBLE,
    description VARCHAR(100),
    date DATE
);

-- Insert sample finance data
INSERT INTO finance (username, type, amount, description, date) 
VALUES ('sidram', 'Income', 5000.00, 'Monthly Salary', '2023-10-01');

INSERT INTO finance (username, type, amount, description, date) 
VALUES ('sidram', 'Expense', 120.50, 'Groceries', '2023-10-05');

INSERT INTO finance (username, type, amount, description, date) 
VALUES ('sidram', 'Investment', 1000.00, 'Stock Market', '2023-10-10');

CREATE TABLE IF NOT EXISTS loans (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50),
    loan_amount DOUBLE,
    date DATE
);
