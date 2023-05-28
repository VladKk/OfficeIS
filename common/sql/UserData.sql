CREATE TABLE IF NOT EXISTS user_details (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    salary DECIMAL(8, 2),
    manager_id INTEGER REFERENCES users(id),
    vacation_days INTEGER DEFAULT 0,
    start_date DATE,
    end_date DATE
);

CREATE TABLE IF NOT EXISTS teams (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS user_teams (
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    team_id INTEGER REFERENCES teams(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, team_id)
);

CREATE OR REPLACE PROCEDURE create_team_with_users(team_name text, user_names text[])
LANGUAGE plpgsql AS $$
DECLARE
    user_name text;
    team_id int;
BEGIN
    INSERT INTO teams (name)
    VALUES (team_name)
    RETURNING id INTO team_id;

    FOREACH user_name IN ARRAY user_names
    LOOP
        EXECUTE format('
            INSERT INTO user_teams (user_id, team_id)
            SELECT id, %L
            FROM users
            WHERE username = %L
        ', team_id, user_name);
    END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION delete_team(team_name text)
RETURNS BOOLEAN LANGUAGE plpgsql AS $$
DECLARE
    team int;
BEGIN
    SELECT id INTO team FROM teams WHERE name = team_name;

    IF team IS NULL THEN
        RETURN FALSE;
    END IF;

    DELETE FROM user_teams WHERE team_id = team;
    DELETE FROM teams WHERE id = team;

    RETURN TRUE;
END;
$$;
