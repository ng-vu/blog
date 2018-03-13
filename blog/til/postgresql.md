# PostgreSQL

PostgreSQL is a poswerful relational DBMS that I use primarily for my projects. This page contains some useful things I learned while working with it.

Website: [postgresql.org](https://www.postgresql.org/)

## Designing schema

### Tracking changes

#### Track all changes on a table

Store changes as JSONB and allow querying latest changes.

```sql
-- Add column "rid" (revision id) to table product
ALTER TABLE product ADD COLUMN IF NOT EXISTS rid INT8;
CREATE INDEX IF NOT EXISTS "IDX_product_rid" ON product(rid);

-- Increase "rid" each time table product get updated
CREATE SEQUENCE IF NOT EXISTS product_history_seq;

CREATE OR REPLACE FUNCTION update_rid() RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    NEW.rid = nextval(TG_ARGV[0]);
    RETURN NEW;
END
$$;

CREATE TRIGGER update_rid BEFORE INSERT OR UPDATE ON product
    FOR EACH ROW EXECUTE PROCEDURE update_rid(product_history_seq);

-- Create new table to store history and insert to it each time table product get updated
CREATE TABLE IF NOT EXISTS product_history (
    rid INT8 PRIMARY KEY,
    product_id INT8,
    deleted BOOLEAN,
    time TIMESTAMPTZ DEFAULT now(),
    data JSONB
);
CREATE INDEX IF NOT EXISTS "IDX_product_history_product_id" ON product_history(product_id);

CREATE OR REPLACE FUNCTION product_history() RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO product_history(rid, product_id, data, deleted)
        VALUES (nextval('product_history_seq'), OLD.id, to_json(OLD), TRUE);
    ELSE
        INSERT INTO product_history(rid, product_id, data)
        VALUES (NEW.rid, NEW.id, to_json(NEW));
    END IF;
    RETURN NULL;
END
$$;

CREATE TRIGGER product_history AFTER INSERT OR UPDATE OR DELETE ON product
    FOR EACH ROW EXECUTE PROCEDURE product_history();
```

#### Store only changed columns 

```sql
create extension hstore;

CREATE OR REPLACE FUNCTION product_history() RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
	changes JSONB;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO product_history(rid, product_id, data, deleted)
        VALUES (nextval('product_history_seq'), OLD.id, to_json(OLD), TRUE);
        
    ELSE IF (TG_OP = 'INSERT') THEN
    	INSERT INTO product_history(rid, product_id, data)
        VALUES (NEW.rid, NEW.id, to_json(OLD));
        
    ELSE
    	-- calculate only changed columns then encode as jsonb
    	-- also ignore uninteresting fields like "updated_at", "rid"
    	changes := to_jsonb((hstore(NEW.*)-hstore(OLD.*)) - '{updated_at,rid}'::TEXT[]);
    	
    	-- ignore trivial changes
    	IF (changes = '{}'::JSONB) THEN RETURN NULL; END IF;
    	
        INSERT INTO product_history(rid, product_id, data)
        VALUES (NEW.rid, NEW.id, to_json(NEW));
    END IF;
    RETURN NULL;
END
$$;
```

