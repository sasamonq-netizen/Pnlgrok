-- Supabase schema.sql file

-- Creating tables
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Row Level Security Policies

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Policy for users to select their own data
CREATE POLICY "Users can view their own data" ON users
    FOR SELECT
    USING (auth.uid() = id);

-- Policy for users to insert their own data
CREATE POLICY "Users can insert their own data" ON posts
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Atomic functions

-- Function to create a new user
CREATE OR REPLACE FUNCTION create_user(username VARCHAR, email VARCHAR)
RETURNS void AS $$
BEGIN
    INSERT INTO users (username, email) VALUES (username, email);
END;
$$ LANGUAGE plpgsql;

-- Function to create a new post
CREATE OR REPLACE FUNCTION create_post(user_id INTEGER, content TEXT)
RETURNS void AS $$
BEGIN
    INSERT INTO posts (user_id, content) VALUES (user_id, content);
END;
$$ LANGUAGE plpgsql;

-- More functions and policies can be added here based on requirements.