SELECT 'CREATE DATABASE mail' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'mail')\gexec
SELECT 'CREATE DATABASE profile_db' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'profile_db')\gexec
SELECT 'CREATE DATABASE team_service' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'team_service')\gexec
SELECT 'CREATE DATABASE task_db' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'task_db')\gexec
SELECT 'CREATE DATABASE conflict' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'conflict')\gexec