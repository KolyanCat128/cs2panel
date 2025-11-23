-- SQL script to grant necessary permissions to cs2panel user
-- Run this as PostgreSQL superuser (postgres) if the application still has permission issues

-- Grant usage on public schema
GRANT USAGE ON SCHEMA public TO cs2panel;
GRANT CREATE ON SCHEMA public TO cs2panel;
GRANT ALL PRIVILEGES ON SCHEMA public TO cs2panel;

-- Create and grant permissions on cs2panel schema
CREATE SCHEMA IF NOT EXISTS cs2panel AUTHORIZATION cs2panel;
GRANT ALL PRIVILEGES ON SCHEMA cs2panel TO cs2panel;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA cs2panel TO cs2panel;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA cs2panel TO cs2panel;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA cs2panel GRANT ALL ON TABLES TO cs2panel;
ALTER DEFAULT PRIVILEGES IN SCHEMA cs2panel GRANT ALL ON SEQUENCES TO cs2panel;

-- Alternatively, make cs2panel owner of the database
-- ALTER DATABASE cs2panel OWNER TO cs2panel;
