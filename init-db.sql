SELECT 'CREATE DATABASE mail' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'mail')\gexec
SELECT 'CREATE DATABASE profile_db' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'profile_db')\gexec
