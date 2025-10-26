-- =====================================================
-- TechMindsForge Database Scripts
-- PostgreSQL Database Setup for Persons Table
-- =====================================================

-- 1. Create the persons table
CREATE TABLE IF NOT EXISTS persons (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    age VARCHAR(10) NOT NULL,
    gender VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_persons_name ON persons(name);
CREATE INDEX IF NOT EXISTS idx_persons_gender ON persons(gender);
CREATE INDEX IF NOT EXISTS idx_persons_created_at ON persons(created_at);

-- 3. Create a function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 4. Create trigger to automatically update updated_at
DROP TRIGGER IF EXISTS update_persons_updated_at ON persons;
CREATE TRIGGER update_persons_updated_at
    BEFORE UPDATE ON persons
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 5. Stored Procedure to Insert Person
CREATE OR REPLACE FUNCTION insert_person(
    p_name VARCHAR(255),
    p_age VARCHAR(10),
    p_gender VARCHAR(50)
)
RETURNS TABLE(
    person_id INTEGER,
    person_name VARCHAR(255),
    person_age VARCHAR(10),
    person_gender VARCHAR(50),
    created_date TIMESTAMP WITH TIME ZONE
) AS $$
DECLARE
    new_person_id INTEGER;
BEGIN
    -- Insert the new person
    INSERT INTO persons (name, age, gender)
    VALUES (p_name, p_age, p_gender)
    RETURNING id INTO new_person_id;
    
    -- Return the inserted person data
    RETURN QUERY
    SELECT 
        p.id,
        p.name,
        p.age,
        p.gender,
        p.created_at
    FROM persons p
    WHERE p.id = new_person_id;
END;
$$ LANGUAGE plpgsql;

-- 6. Stored Procedure to Get All Persons with Pagination
CREATE OR REPLACE FUNCTION get_persons_paginated(
    p_page INTEGER DEFAULT 1,
    p_size INTEGER DEFAULT 10
)
RETURNS TABLE(
    person_id INTEGER,
    person_name VARCHAR(255),
    person_age VARCHAR(10),
    person_gender VARCHAR(50),
    created_date TIMESTAMP WITH TIME ZONE,
    total_count BIGINT
) AS $$
DECLARE
    offset_value INTEGER;
BEGIN
    -- Calculate offset
    offset_value := (p_page - 1) * p_size;
    
    -- Return paginated results with total count
    RETURN QUERY
    SELECT 
        p.id,
        p.name,
        p.age,
        p.gender,
        p.created_at,
        COUNT(*) OVER() as total_count
    FROM persons p
    ORDER BY p.created_at DESC
    LIMIT p_size OFFSET offset_value;
END;
$$ LANGUAGE plpgsql;

-- 7. Stored Procedure to Search Persons by Name
CREATE OR REPLACE FUNCTION search_persons_by_name(
    p_search_name VARCHAR(255)
)
RETURNS TABLE(
    person_id INTEGER,
    person_name VARCHAR(255),
    person_age VARCHAR(10),
    person_gender VARCHAR(50),
    created_date TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.name,
        p.age,
        p.gender,
        p.created_at
    FROM persons p
    WHERE LOWER(p.name) LIKE LOWER('%' || p_search_name || '%')
    ORDER BY p.name;
END;
$$ LANGUAGE plpgsql;

-- 8. Stored Procedure to Update Person
CREATE OR REPLACE FUNCTION update_person(
    p_person_id INTEGER,
    p_name VARCHAR(255) DEFAULT NULL,
    p_age VARCHAR(10) DEFAULT NULL,
    p_gender VARCHAR(50) DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message VARCHAR(255),
    person_id INTEGER,
    person_name VARCHAR(255),
    person_age VARCHAR(10),
    person_gender VARCHAR(50)
) AS $$
DECLARE
    person_exists BOOLEAN;
BEGIN
    -- Check if person exists
    SELECT EXISTS(SELECT 1 FROM persons WHERE id = p_person_id) INTO person_exists;
    
    IF NOT person_exists THEN
        RETURN QUERY SELECT FALSE, 'Person not found', 0, '', '', '';
        RETURN;
    END IF;
    
    -- Update person with provided values
    UPDATE persons 
    SET 
        name = COALESCE(p_name, name),
        age = COALESCE(p_age, age),
        gender = COALESCE(p_gender, gender),
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_person_id;
    
    -- Return updated person data
    RETURN QUERY
    SELECT 
        TRUE,
        'Person updated successfully',
        p.id,
        p.name,
        p.age,
        p.gender
    FROM persons p
    WHERE p.id = p_person_id;
END;
$$ LANGUAGE plpgsql;

-- 9. Stored Procedure to Delete Person
CREATE OR REPLACE FUNCTION delete_person(
    p_person_id INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    message VARCHAR(255),
    deleted_person_name VARCHAR(255)
) AS $$
DECLARE
    person_name VARCHAR(255);
    person_exists BOOLEAN;
BEGIN
    -- Get person name before deletion
    SELECT name INTO person_name FROM persons WHERE id = p_person_id;
    
    -- Check if person exists
    SELECT EXISTS(SELECT 1 FROM persons WHERE id = p_person_id) INTO person_exists;
    
    IF NOT person_exists THEN
        RETURN QUERY SELECT FALSE, 'Person not found', '';
        RETURN;
    END IF;
    
    -- Delete the person
    DELETE FROM persons WHERE id = p_person_id;
    
    -- Return success message
    RETURN QUERY SELECT TRUE, 'Person deleted successfully', person_name;
END;
$$ LANGUAGE plpgsql;

-- 10. Grant permissions (adjust as needed for your setup)
-- GRANT ALL PRIVILEGES ON TABLE persons TO postgres;
-- GRANT ALL PRIVILEGES ON SEQUENCE persons_id_seq TO postgres;

-- =====================================================
-- Example Usage:
-- =====================================================

-- Insert a person using stored procedure:
-- SELECT * FROM insert_person('John Doe', '25', 'Male');

-- Get all persons with pagination:
-- SELECT * FROM get_persons_paginated(1, 10);

-- Search persons by name:
-- SELECT * FROM search_persons_by_name('John');

-- Update a person:
-- SELECT * FROM update_person(1, 'John Smith', '26', 'Male');

-- Delete a person:
-- SELECT * FROM delete_person(1);

-- =====================================================
-- Verification Queries:
-- =====================================================

-- Check if table exists:
-- SELECT table_name FROM information_schema.tables WHERE table_name = 'persons';

-- Check table structure:
-- \d persons

-- Check functions:
-- SELECT routine_name FROM information_schema.routines WHERE routine_name LIKE '%person%';
