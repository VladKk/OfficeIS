CREATE TABLE IF NOT EXISTS projects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS user_projects (
    user_id INTEGER REFERENCES users(id),
    project_id INTEGER REFERENCES projects(id),
    PRIMARY KEY (user_id, project_id)
);
