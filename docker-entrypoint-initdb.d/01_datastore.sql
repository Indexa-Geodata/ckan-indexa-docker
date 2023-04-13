\set postgres_user  `echo $POSTGRES_USER`
\set datastore_user  `echo $DATASTORE_USER` 
\set postgres_db  `echo $POSTGRES_DB` 
\set datastore_db `echo $POSTGRES_DATABASE_DATASTORE` 

REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE USAGE ON SCHEMA public FROM PUBLIC;

GRANT CREATE ON SCHEMA public TO :postgres_user;
GRANT USAGE ON SCHEMA public TO :postgres_user;

GRANT CREATE ON SCHEMA public TO :datastore_user;
GRANT USAGE ON SCHEMA public TO :datastore_user;


REVOKE CONNECT ON DATABASE :postgres_db FROM :datastore_user;


GRANT CONNECT ON DATABASE :datastore_db TO :datastore_user;
GRANT USAGE ON SCHEMA public TO :datastore_user;


GRANT SELECT ON ALL TABLES IN SCHEMA public TO :datastore_user;


ALTER DEFAULT PRIVILEGES FOR USER :datastore_user IN SCHEMA public
   GRANT SELECT ON TABLES TO :datastore_user;


CREATE OR REPLACE VIEW "_table_metadata" AS
    SELECT DISTINCT
        substr(md5(dependee.relname || COALESCE(dependent.relname, '')), 0, 17) AS "_id",
        dependee.relname AS name,
        dependee.oid AS oid,
        dependent.relname AS alias_of
    FROM
        pg_class AS dependee
        LEFT OUTER JOIN pg_rewrite AS r ON r.ev_class = dependee.oid
        LEFT OUTER JOIN pg_depend AS d ON d.objid = r.oid
        LEFT OUTER JOIN pg_class AS dependent ON d.refobjid = dependent.oid
    WHERE
        (dependee.oid != dependent.oid OR dependent.oid IS NULL) AND
        -- is a table (from pg_tables view definition)
        -- or is a view (from pg_views view definition)
        (dependee.relkind = 'r'::"char" OR dependee.relkind = 'v'::"char")
        AND dependee.relnamespace = (
            SELECT oid FROM pg_namespace WHERE nspname='public')
    ORDER BY dependee.oid DESC;
ALTER VIEW "_table_metadata" OWNER TO :datastore_user;
GRANT SELECT ON "_table_metadata" TO :datastore_user;


CREATE OR REPLACE FUNCTION populate_full_text_trigger() RETURNS trigger
AS $body$
    BEGIN
        IF NEW._full_text IS NOT NULL THEN
            RETURN NEW;
        END IF;
        NEW._full_text := (
            SELECT to_tsvector(string_agg(value, ' '))
            FROM json_each_text(row_to_json(NEW.*))
            WHERE key NOT LIKE '\_%');
        RETURN NEW;
    END;
$body$ LANGUAGE plpgsql;
ALTER FUNCTION populate_full_text_trigger() OWNER TO :datastore_user;


DO $body$
    BEGIN
        EXECUTE coalesce(
            (SELECT string_agg(
                'CREATE TRIGGER zfulltext BEFORE INSERT OR UPDATE ON ' ||
                quote_ident(relname) || ' FOR EACH ROW EXECUTE PROCEDURE ' ||
                'populate_full_text_trigger();', ' ')
            FROM pg_class
            LEFT OUTER JOIN pg_trigger AS t
                ON t.tgrelid = relname::regclass AND t.tgname = 'zfulltext'
            WHERE relkind = 'r'::"char" AND t.tgname IS NULL
                AND relnamespace = (
                    SELECT oid FROM pg_namespace WHERE nspname='public')),
            'SELECT 1;');
    END;
$body$;
