DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'equipment_status') THEN
        CREATE TYPE equipment_status AS ENUM ('AVAILABLE', 'IN_USE', 'IN_REPAIR', 'RETIRED');
    END IF;
END$$;

CREATE TABLE IF NOT EXISTS equipment (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    user_id INTEGER REFERENCES users(id),
    inventory_number VARCHAR(255) NOT NULL,
    status equipment_status NOT NULL DEFAULT 'AVAILABLE'
);
