DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'task_status') THEN
        CREATE TYPE task_status AS ENUM ('TO DO', 'IN PROGRESS', 'DONE');
    END IF;
END$$;

CREATE TABLE IF NOT EXISTS tasks (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    user_id INTEGER REFERENCES users(id),
    parent_project_id INTEGER REFERENCES projects(id),
    status task_status NOT NULL DEFAULT 'TO DO',
    due_date DATE
);
