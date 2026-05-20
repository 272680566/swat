-- Run this script to create the database and users table

CREATE DATABASE swat;

-- Then connect to swat database and run:

CREATE TABLE IF NOT EXISTS users (
    id          BIGSERIAL    PRIMARY KEY,
    username    VARCHAR(50)  NOT NULL UNIQUE,
    password    VARCHAR(255) NOT NULL,
    email       VARCHAR(100) DEFAULT '',
    created_at  TIMESTAMP    DEFAULT NOW()
);

-- Insert a test user (password: 123456, BCrypt encoded)
INSERT INTO users (username, password, email) VALUES
('admin', '$2a$10$TfupDkYOm6mFBJq/x1To2ebZTUcjT0BJipz6T0LiMpGX.TAGcSSHa', 'admin@swat.com');
