DO $$
    DECLARE
        current_length INTEGER;
    BEGIN
        SELECT atttypmod - 4 INTO current_length
        FROM pg_attribute
                 JOIN pg_class ON pg_class.oid = pg_attribute.attrelid
                 JOIN pg_namespace ON pg_namespace.oid = pg_class.relnamespace
        WHERE pg_class.relname = 'calculation_field'
          AND pg_namespace.nspname = 'public'
          AND pg_attribute.attname = 'script';

        IF current_length IS NULL OR current_length < 51200 THEN
            ALTER TABLE calculation_field ALTER COLUMN script TYPE VARCHAR(51200);
        END IF;
    END $$;
