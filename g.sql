docker run --rm -i postgres:16 bash -c "
PGPASSWORD='developer' pg_dump --host=pgbouncer00.s01a0001.entrata.io --port=6400 --username=psDeveloper --dbname=insurance_stage --schema-only --no-owner --no-privileges --section=pre-data | \
PGPASSWORD='dba' psql --host=pgbouncer00.d05d0001.entrata.io --port=6400 --username=psDba --dbname=insurance_dev"


docker run --rm -i postgres:16 bash -c "
PGPASSWORD='developer' psql -h pgbouncer00.s01a0001.entrata.io -p 6400 -U psDeveloper -d insurance_stage -tA -c \"
SELECT pg_get_functiondef(p.oid) || ';'
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname NOT IN ('pg_catalog', 'information_schema');
\" | \
PGPASSWORD='dba' psql -h pgbouncer00.d05d0001.entrata.io -p 6400 -U psDba -d insurance_dev"



docker run --rm -i postgres:16 bash -c "
PGPASSWORD='developer' psql -h pgbouncer00.s01a0001.entrata.io -p 6400 -U psDeveloper -d insurance_stage -tA -c \"
SELECT pg_get_functiondef(p.oid) || ';'
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
JOIN pg_language l ON p.prolang = l.oid
WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
AND l.lanname IN ('sql', 'plpgsql');
\" \
| PGPASSWORD='dba' psql -h pgbouncer00.d05d0001.entrata.io -p 6400 -U psDba -d insurance_dev"


docker run --rm -i postgres:16 bash -c '
PGPASSWORD="developer" psql -h pgbouncer00.s01a0001.entrata.io -p 6400 -U psDeveloper -d insurance_stage -tA -F $'\''\n'\'' -c "
SELECT
CASE
  WHEN c.contype = '\''c'\'' THEN
    '\''ALTER TABLE '\'' || quote_ident(n.nspname) || '\''.'\'' || quote_ident(t.relname) ||
    '\'' DROP CONSTRAINT IF EXISTS '\'' || quote_ident(c.conname) || '\''; '\'' ||
    '\''ALTER TABLE '\'' || quote_ident(n.nspname) || '\''.'\'' || quote_ident(t.relname) ||
    '\'' ADD CONSTRAINT '\'' || quote_ident(c.conname) || '\'' '\'' || pg_get_constraintdef(c.oid) || '\'';'\''
  ELSE
    '\''DO $$ DECLARE sql text; BEGIN
      IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = '\'''\'' || c.conname || '\'''\'' AND conrelid = '\'''\'' || c.conrelid || '\'''\'
      ) THEN
        sql := '\''ALTER TABLE '\'' || quote_ident(n.nspname) || '\''.'\'' || quote_ident(t.relname) ||
               '\'' ADD CONSTRAINT '\'' || quote_ident(c.conname) || '\'' '\'' || pg_get_constraintdef(c.oid) || '\'';'\'';
        EXECUTE sql;
      END IF;
    END $$;'\'' 
END
FROM pg_constraint c
JOIN pg_class t ON c.conrelid = t.oid
JOIN pg_namespace n ON t.relnamespace = n.oid
WHERE n.nspname = '\''public'\'';
" | PGPASSWORD="dba" psql -h pgbouncer00.d05d0001.entrata.io -p 6400 -U psDba -d insurance_dev'




-- DROP FUNCTION public._int_contained(_int4, _int4);

CREATE OR REPLACE FUNCTION public._int_contained(integer[], integer[])
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$_int_contained$function$
;

COMMENT ON FUNCTION public._int_contained(_int4, _int4) IS 'contained in';

-- DROP FUNCTION public._int_contained_joinsel(internal, oid, internal, int2, internal);

CREATE OR REPLACE FUNCTION public._int_contained_joinsel(internal, oid, internal, smallint, internal)
 RETURNS double precision
 LANGUAGE c
 STABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$_int_contained_joinsel$function$
;

-- DROP FUNCTION public._int_contained_sel(internal, oid, internal, int4);

CREATE OR REPLACE FUNCTION public._int_contained_sel(internal, oid, internal, integer)
 RETURNS double precision
 LANGUAGE c
 STABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$_int_contained_sel$function$
;

-- DROP FUNCTION public._int_contains(_int4, _int4);

CREATE OR REPLACE FUNCTION public._int_contains(integer[], integer[])
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$_int_contains$function$
;

COMMENT ON FUNCTION public._int_contains(_int4, _int4) IS 'contains';

-- DROP FUNCTION public._int_contains_joinsel(internal, oid, internal, int2, internal);

CREATE OR REPLACE FUNCTION public._int_contains_joinsel(internal, oid, internal, smallint, internal)
 RETURNS double precision
 LANGUAGE c
 STABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$_int_contains_joinsel$function$
;

-- DROP FUNCTION public._int_contains_sel(internal, oid, internal, int4);

CREATE OR REPLACE FUNCTION public._int_contains_sel(internal, oid, internal, integer)
 RETURNS double precision
 LANGUAGE c
 STABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$_int_contains_sel$function$
;

-- DROP FUNCTION public._int_different(_int4, _int4);

CREATE OR REPLACE FUNCTION public._int_different(integer[], integer[])
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$_int_different$function$
;

COMMENT ON FUNCTION public._int_different(_int4, _int4) IS 'different';

-- DROP FUNCTION public._int_inter(_int4, _int4);

CREATE OR REPLACE FUNCTION public._int_inter(integer[], integer[])
 RETURNS integer[]
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$_int_inter$function$
;

-- DROP FUNCTION public._int_matchsel(internal, oid, internal, int4);

CREATE OR REPLACE FUNCTION public._int_matchsel(internal, oid, internal, integer)
 RETURNS double precision
 LANGUAGE c
 STABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$_int_matchsel$function$
;

-- DROP FUNCTION public._int_overlap(_int4, _int4);

CREATE OR REPLACE FUNCTION public._int_overlap(integer[], integer[])
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$_int_overlap$function$
;

COMMENT ON FUNCTION public._int_overlap(_int4, _int4) IS 'overlaps';

-- DROP FUNCTION public._int_overlap_joinsel(internal, oid, internal, int2, internal);

CREATE OR REPLACE FUNCTION public._int_overlap_joinsel(internal, oid, internal, smallint, internal)
 RETURNS double precision
 LANGUAGE c
 STABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$_int_overlap_joinsel$function$
;

-- DROP FUNCTION public._int_overlap_sel(internal, oid, internal, int4);

CREATE OR REPLACE FUNCTION public._int_overlap_sel(internal, oid, internal, integer)
 RETURNS double precision
 LANGUAGE c
 STABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$_int_overlap_sel$function$
;

-- DROP FUNCTION public._int_same(_int4, _int4);

CREATE OR REPLACE FUNCTION public._int_same(integer[], integer[])
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$_int_same$function$
;

COMMENT ON FUNCTION public._int_same(_int4, _int4) IS 'same as';

-- DROP FUNCTION public._int_union(_int4, _int4);

CREATE OR REPLACE FUNCTION public._int_union(integer[], integer[])
 RETURNS integer[]
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$_int_union$function$
;

-- DROP FUNCTION public._intbig_in(cstring);

CREATE OR REPLACE FUNCTION public._intbig_in(cstring)
 RETURNS intbig_gkey
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$_intbig_in$function$
;

-- DROP FUNCTION public._intbig_out(intbig_gkey);

CREATE OR REPLACE FUNCTION public._intbig_out(intbig_gkey)
 RETURNS cstring
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$_intbig_out$function$
;

-- DROP FUNCTION public.akeys(hstore);

CREATE OR REPLACE FUNCTION public.akeys(hstore)
 RETURNS text[]
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_akeys$function$
;

-- DROP FUNCTION public.avals(hstore);

CREATE OR REPLACE FUNCTION public.avals(hstore)
 RETURNS text[]
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_avals$function$
;

-- DROP FUNCTION public.awsdms_intercept_ddl();

CREATE OR REPLACE FUNCTION public.awsdms_intercept_ddl()
 RETURNS event_trigger
 LANGUAGE plpgsql
AS $function$
  declare _qry text;
BEGIN
  if (tg_tag='CREATE TABLE' or tg_tag='ALTER TABLE' or tg_tag='DROP TABLE') then
	    SELECT current_query() into _qry;
	    insert into public.awsdms_ddl_audit
	    values
	    (
	    default,current_timestamp,current_user,cast(TXID_CURRENT()as varchar(16)),tg_tag,0,'',current_schema,_qry
	    );
	    delete from public.awsdms_ddl_audit;
 end if;
END;
$function$
;

-- DROP FUNCTION public.boolop(_int4, query_int);

CREATE OR REPLACE FUNCTION public.boolop(integer[], query_int)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$boolop$function$
;

COMMENT ON FUNCTION public.boolop(_int4, query_int) IS 'boolean operation with array';

-- DROP FUNCTION public.bqarr_in(cstring);

CREATE OR REPLACE FUNCTION public.bqarr_in(cstring)
 RETURNS query_int
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$bqarr_in$function$
;

-- DROP FUNCTION public.bqarr_out(query_int);

CREATE OR REPLACE FUNCTION public.bqarr_out(query_int)
 RETURNS cstring
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$bqarr_out$function$
;

-- DROP FUNCTION public.check_data_exist(int4, text, int4);

CREATE OR REPLACE FUNCTION public.check_data_exist(integer, text, integer)
 RETURNS TABLE(tablename text, record_count integer)
 LANGUAGE plpgsql
AS $function$
DECLARE row RECORD;
DECLARE have_records INTEGER;
DECLARE sql11 TEXT;
DECLARE pClientId ALIAS FOR $1;
DECLARE pColumnName ALIAS FOR $2;
DECLARE pCoulmnValue ALIAS FOR $3;
BEGIN       
    FOR row IN
SELECT
table_name,
column_name
FROM
information_schema.columns
WHERE
column_name ILIKE '%' || pColumnName
AND table_schema = 'public'
AND table_name NOT LIKE 'view%'
AND table_name NOT LIKE '%old%'
AND table_name NOT LIKE 'temp%'
AND table_name NOT LIKE 'default%'
AND table_name NOT LIKE 'xyzzy%'
AND table_name NOT LIKE 'unit_space_rate_logs_before_megarates'
        
    LOOP
    
        sql11 := 'SELECT 
                        COUNT(*) 
                    FROM 
                        ' || quote_ident(row.table_name) || ' 
                    WHERE 
                        cid = ' || pClientId || '
                        AND ' || quote_ident(row.column_name) || ' = ' || pCoulmnValue;
        
          EXECUTE sql11 INTO have_records;
        
        -- Return table name
        IF have_records > 0 THEN
            RETURN QUERY EXECUTE '
                    SELECT 
                     ''' ||  quote_ident(row.table_name) || '''::TEXT AS tablename,
						COUNT(1)::INTEGER AS record_count
                    FROM  
                        ' ||  quote_ident(row.table_name) || ' 
                    WHERE 
                        cid = ' || pClientId || '
                        AND ' || quote_ident(row.column_name) || ' = ' || pCoulmnValue;
        END IF;
        
    END LOOP;
END;
$function$
;

-- DROP FUNCTION public.connectby(text, text, text, text, int4);

CREATE OR REPLACE FUNCTION public.connectby(text, text, text, text, integer)
 RETURNS SETOF record
 LANGUAGE c
 STABLE STRICT
AS '$libdir/tablefunc', $function$connectby_text$function$
;

-- DROP FUNCTION public.connectby(text, text, text, text, int4, text);

CREATE OR REPLACE FUNCTION public.connectby(text, text, text, text, integer, text)
 RETURNS SETOF record
 LANGUAGE c
 STABLE STRICT
AS '$libdir/tablefunc', $function$connectby_text$function$
;

-- DROP FUNCTION public.connectby(text, text, text, text, text, int4);

CREATE OR REPLACE FUNCTION public.connectby(text, text, text, text, text, integer)
 RETURNS SETOF record
 LANGUAGE c
 STABLE STRICT
AS '$libdir/tablefunc', $function$connectby_text_serial$function$
;

-- DROP FUNCTION public.connectby(text, text, text, text, text, int4, text);

CREATE OR REPLACE FUNCTION public.connectby(text, text, text, text, text, integer, text)
 RETURNS SETOF record
 LANGUAGE c
 STABLE STRICT
AS '$libdir/tablefunc', $function$connectby_text_serial$function$
;

-- DROP FUNCTION public.count_rows_of_table(text, text);

CREATE OR REPLACE FUNCTION public.count_rows_of_table(schema text, tablename text)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
declare
  query_template constant text not null :=
    '
      select count(*) from "?schema"."?tablename"
    ';

  query constant text not null :=
    replace(
      replace(
        query_template, '?schema', schema),
     '?tablename', tablename);

  result int not null := -1;
begin
  execute query into result;
  return result;
end;
$function$
;

-- DROP FUNCTION public.crosstab2(text);

CREATE OR REPLACE FUNCTION public.crosstab2(text)
 RETURNS SETOF tablefunc_crosstab_2
 LANGUAGE c
 STABLE STRICT
AS '$libdir/tablefunc', $function$crosstab$function$
;

-- DROP FUNCTION public.crosstab3(text);

CREATE OR REPLACE FUNCTION public.crosstab3(text)
 RETURNS SETOF tablefunc_crosstab_3
 LANGUAGE c
 STABLE STRICT
AS '$libdir/tablefunc', $function$crosstab$function$
;

-- DROP FUNCTION public.crosstab4(text);

CREATE OR REPLACE FUNCTION public.crosstab4(text)
 RETURNS SETOF tablefunc_crosstab_4
 LANGUAGE c
 STABLE STRICT
AS '$libdir/tablefunc', $function$crosstab$function$
;

-- DROP FUNCTION public.crosstab(text);

CREATE OR REPLACE FUNCTION public.crosstab(text)
 RETURNS SETOF record
 LANGUAGE c
 STABLE STRICT
AS '$libdir/tablefunc', $function$crosstab$function$
;

-- DROP FUNCTION public.crosstab(text, int4);

CREATE OR REPLACE FUNCTION public.crosstab(text, integer)
 RETURNS SETOF record
 LANGUAGE c
 STABLE STRICT
AS '$libdir/tablefunc', $function$crosstab$function$
;

-- DROP FUNCTION public.crosstab(text, text);

CREATE OR REPLACE FUNCTION public.crosstab(text, text)
 RETURNS SETOF record
 LANGUAGE c
 STABLE STRICT
AS '$libdir/tablefunc', $function$crosstab_hash$function$
;

-- DROP FUNCTION public.dblink(text);

CREATE OR REPLACE FUNCTION public.dblink(text)
 RETURNS SETOF record
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_record$function$
;

-- DROP FUNCTION public.dblink(text, bool);

CREATE OR REPLACE FUNCTION public.dblink(text, boolean)
 RETURNS SETOF record
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_record$function$
;

-- DROP FUNCTION public.dblink(text, text);

CREATE OR REPLACE FUNCTION public.dblink(text, text)
 RETURNS SETOF record
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_record$function$
;

-- DROP FUNCTION public.dblink(text, text, bool);

CREATE OR REPLACE FUNCTION public.dblink(text, text, boolean)
 RETURNS SETOF record
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_record$function$
;

-- DROP FUNCTION public.dblink_build_sql_delete(text, int2vector, int4, _text);

CREATE OR REPLACE FUNCTION public.dblink_build_sql_delete(text, int2vector, integer, text[])
 RETURNS text
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_build_sql_delete$function$
;

-- DROP FUNCTION public.dblink_build_sql_insert(text, int2vector, int4, _text, _text);

CREATE OR REPLACE FUNCTION public.dblink_build_sql_insert(text, int2vector, integer, text[], text[])
 RETURNS text
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_build_sql_insert$function$
;

-- DROP FUNCTION public.dblink_build_sql_update(text, int2vector, int4, _text, _text);

CREATE OR REPLACE FUNCTION public.dblink_build_sql_update(text, int2vector, integer, text[], text[])
 RETURNS text
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_build_sql_update$function$
;

-- DROP FUNCTION public.dblink_cancel_query(text);

CREATE OR REPLACE FUNCTION public.dblink_cancel_query(text)
 RETURNS text
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_cancel_query$function$
;

-- DROP FUNCTION public.dblink_close(text);

CREATE OR REPLACE FUNCTION public.dblink_close(text)
 RETURNS text
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_close$function$
;

-- DROP FUNCTION public.dblink_close(text, bool);

CREATE OR REPLACE FUNCTION public.dblink_close(text, boolean)
 RETURNS text
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_close$function$
;

-- DROP FUNCTION public.dblink_close(text, text);

CREATE OR REPLACE FUNCTION public.dblink_close(text, text)
 RETURNS text
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_close$function$
;

-- DROP FUNCTION public.dblink_close(text, text, bool);

CREATE OR REPLACE FUNCTION public.dblink_close(text, text, boolean)
 RETURNS text
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_close$function$
;

-- DROP FUNCTION public.dblink_connect(text);

CREATE OR REPLACE FUNCTION public.dblink_connect(text)
 RETURNS text
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_connect$function$
;

-- DROP FUNCTION public.dblink_connect(text, text);

CREATE OR REPLACE FUNCTION public.dblink_connect(text, text)
 RETURNS text
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_connect$function$
;

-- DROP FUNCTION public.dblink_connect_u(text);

CREATE OR REPLACE FUNCTION public.dblink_connect_u(text)
 RETURNS text
 LANGUAGE c
 PARALLEL RESTRICTED STRICT SECURITY DEFINER
AS '$libdir/dblink', $function$dblink_connect$function$
;

-- DROP FUNCTION public.dblink_connect_u(text, text);

CREATE OR REPLACE FUNCTION public.dblink_connect_u(text, text)
 RETURNS text
 LANGUAGE c
 PARALLEL RESTRICTED STRICT SECURITY DEFINER
AS '$libdir/dblink', $function$dblink_connect$function$
;

-- DROP FUNCTION public.dblink_current_query();

CREATE OR REPLACE FUNCTION public.dblink_current_query()
 RETURNS text
 LANGUAGE c
 PARALLEL RESTRICTED
AS '$libdir/dblink', $function$dblink_current_query$function$
;

-- DROP FUNCTION public.dblink_disconnect();

CREATE OR REPLACE FUNCTION public.dblink_disconnect()
 RETURNS text
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_disconnect$function$
;

-- DROP FUNCTION public.dblink_disconnect(text);

CREATE OR REPLACE FUNCTION public.dblink_disconnect(text)
 RETURNS text
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_disconnect$function$
;

-- DROP FUNCTION public.dblink_error_message(text);

CREATE OR REPLACE FUNCTION public.dblink_error_message(text)
 RETURNS text
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_error_message$function$
;

-- DROP FUNCTION public.dblink_exec(text);

CREATE OR REPLACE FUNCTION public.dblink_exec(text)
 RETURNS text
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_exec$function$
;

-- DROP FUNCTION public.dblink_exec(text, bool);

CREATE OR REPLACE FUNCTION public.dblink_exec(text, boolean)
 RETURNS text
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_exec$function$
;

-- DROP FUNCTION public.dblink_exec(text, text);

CREATE OR REPLACE FUNCTION public.dblink_exec(text, text)
 RETURNS text
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_exec$function$
;

-- DROP FUNCTION public.dblink_exec(text, text, bool);

CREATE OR REPLACE FUNCTION public.dblink_exec(text, text, boolean)
 RETURNS text
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_exec$function$
;

-- DROP FUNCTION public.dblink_fdw_validator(_text, oid);

CREATE OR REPLACE FUNCTION public.dblink_fdw_validator(options text[], catalog oid)
 RETURNS void
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/dblink', $function$dblink_fdw_validator$function$
;

-- DROP FUNCTION public.dblink_fetch(text, int4);

CREATE OR REPLACE FUNCTION public.dblink_fetch(text, integer)
 RETURNS SETOF record
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_fetch$function$
;

-- DROP FUNCTION public.dblink_fetch(text, int4, bool);

CREATE OR REPLACE FUNCTION public.dblink_fetch(text, integer, boolean)
 RETURNS SETOF record
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_fetch$function$
;

-- DROP FUNCTION public.dblink_fetch(text, text, int4);

CREATE OR REPLACE FUNCTION public.dblink_fetch(text, text, integer)
 RETURNS SETOF record
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_fetch$function$
;

-- DROP FUNCTION public.dblink_fetch(text, text, int4, bool);

CREATE OR REPLACE FUNCTION public.dblink_fetch(text, text, integer, boolean)
 RETURNS SETOF record
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_fetch$function$
;

-- DROP FUNCTION public.dblink_get_connections();

CREATE OR REPLACE FUNCTION public.dblink_get_connections()
 RETURNS text[]
 LANGUAGE c
 PARALLEL RESTRICTED
AS '$libdir/dblink', $function$dblink_get_connections$function$
;

-- DROP FUNCTION public.dblink_get_notify(in text, out text, out int4, out text);

CREATE OR REPLACE FUNCTION public.dblink_get_notify(conname text, OUT notify_name text, OUT be_pid integer, OUT extra text)
 RETURNS SETOF record
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_get_notify$function$
;

-- DROP FUNCTION public.dblink_get_notify(out text, out int4, out text);

CREATE OR REPLACE FUNCTION public.dblink_get_notify(OUT notify_name text, OUT be_pid integer, OUT extra text)
 RETURNS SETOF record
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_get_notify$function$
;

-- DROP FUNCTION public.dblink_get_pkey(text);

CREATE OR REPLACE FUNCTION public.dblink_get_pkey(text)
 RETURNS SETOF dblink_pkey_results
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_get_pkey$function$
;

-- DROP FUNCTION public.dblink_get_result(text);

CREATE OR REPLACE FUNCTION public.dblink_get_result(text)
 RETURNS SETOF record
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_get_result$function$
;

-- DROP FUNCTION public.dblink_get_result(text, bool);

CREATE OR REPLACE FUNCTION public.dblink_get_result(text, boolean)
 RETURNS SETOF record
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_get_result$function$
;

-- DROP FUNCTION public.dblink_is_busy(text);

CREATE OR REPLACE FUNCTION public.dblink_is_busy(text)
 RETURNS integer
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_is_busy$function$
;

-- DROP FUNCTION public.dblink_open(text, text);

CREATE OR REPLACE FUNCTION public.dblink_open(text, text)
 RETURNS text
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_open$function$
;

-- DROP FUNCTION public.dblink_open(text, text, bool);

CREATE OR REPLACE FUNCTION public.dblink_open(text, text, boolean)
 RETURNS text
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_open$function$
;

-- DROP FUNCTION public.dblink_open(text, text, text);

CREATE OR REPLACE FUNCTION public.dblink_open(text, text, text)
 RETURNS text
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_open$function$
;

-- DROP FUNCTION public.dblink_open(text, text, text, bool);

CREATE OR REPLACE FUNCTION public.dblink_open(text, text, text, boolean)
 RETURNS text
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_open$function$
;

-- DROP FUNCTION public.dblink_send_query(text, text);

CREATE OR REPLACE FUNCTION public.dblink_send_query(text, text)
 RETURNS integer
 LANGUAGE c
 PARALLEL RESTRICTED STRICT
AS '$libdir/dblink', $function$dblink_send_query$function$
;

-- DROP FUNCTION public."defined"(hstore, text);

CREATE OR REPLACE FUNCTION public.defined(hstore, text)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_defined$function$
;

-- DROP FUNCTION public."delete"(hstore, _text);

CREATE OR REPLACE FUNCTION public.delete(hstore, text[])
 RETURNS hstore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_delete_array$function$
;

-- DROP FUNCTION public."delete"(hstore, hstore);

CREATE OR REPLACE FUNCTION public.delete(hstore, hstore)
 RETURNS hstore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_delete_hstore$function$
;

-- DROP FUNCTION public."delete"(hstore, text);

CREATE OR REPLACE FUNCTION public.delete(hstore, text)
 RETURNS hstore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_delete$function$
;

-- DROP FUNCTION public."each"(in hstore, out text, out text);

CREATE OR REPLACE FUNCTION public.each(hs hstore, OUT key text, OUT value text)
 RETURNS SETOF record
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_each$function$
;

-- DROP FUNCTION public.exist(hstore, text);

CREATE OR REPLACE FUNCTION public.exist(hstore, text)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_exists$function$
;

-- DROP FUNCTION public.exists_all(hstore, _text);

CREATE OR REPLACE FUNCTION public.exists_all(hstore, text[])
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_exists_all$function$
;

-- DROP FUNCTION public.exists_any(hstore, _text);

CREATE OR REPLACE FUNCTION public.exists_any(hstore, text[])
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_exists_any$function$
;

-- DROP FUNCTION public.fetchval(hstore, text);

CREATE OR REPLACE FUNCTION public.fetchval(hstore, text)
 RETURNS text
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_fetchval$function$
;

-- DROP FUNCTION public.fsym_on_d_for_sym_chnnl_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_d_for_sym_chnnl_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                               
                                    values(                                                                                                                                                            
                                      'sym_channel',                                                                                                                                            
                                      'D',                                                                                                                                                             
                                      27,                                                                                                                                             
                                      
          case when old."channel_id" is null then '' else '"' || replace(replace(cast(old."channel_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      null,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_d_for_sym_cnflct_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_d_for_sym_cnflct_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                               
                                    values(                                                                                                                                                            
                                      'sym_conflict',                                                                                                                                            
                                      'D',                                                                                                                                                             
                                      25,                                                                                                                                             
                                      
          case when old."conflict_id" is null then '' else '"' || replace(replace(cast(old."conflict_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      null,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_d_for_sym_fl_trggr_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_d_for_sym_fl_trggr_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                               
                                    values(                                                                                                                                                            
                                      'sym_file_trigger',                                                                                                                                            
                                      'D',                                                                                                                                                             
                                      12,                                                                                                                                             
                                      
          case when old."trigger_id" is null then '' else '"' || replace(replace(cast(old."trigger_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      null,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_d_for_sym_fl_trggr_rtr_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_d_for_sym_fl_trggr_rtr_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                               
                                    values(                                                                                                                                                            
                                      'sym_file_trigger_router',                                                                                                                                            
                                      'D',                                                                                                                                                             
                                      6,                                                                                                                                             
                                      
          case when old."trigger_id" is null then '' else '"' || replace(replace(cast(old."trigger_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."router_id" is null then '' else '"' || replace(replace(cast(old."router_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      null,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_d_for_sym_grplt_lnk_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_d_for_sym_grplt_lnk_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                               
                                    values(                                                                                                                                                            
                                      'sym_grouplet_link',                                                                                                                                            
                                      'D',                                                                                                                                                             
                                      9,                                                                                                                                             
                                      
          case when old."grouplet_id" is null then '' else '"' || replace(replace(cast(old."grouplet_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."external_id" is null then '' else '"' || replace(replace(cast(old."external_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      null,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_d_for_sym_grplt_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_d_for_sym_grplt_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                               
                                    values(                                                                                                                                                            
                                      'sym_grouplet',                                                                                                                                            
                                      'D',                                                                                                                                                             
                                      10,                                                                                                                                             
                                      
          case when old."grouplet_id" is null then '' else '"' || replace(replace(cast(old."grouplet_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      null,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_d_for_sym_jb_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_d_for_sym_jb_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                               
                                    values(                                                                                                                                                            
                                      'sym_job',                                                                                                                                            
                                      'D',                                                                                                                                                             
                                      14,                                                                                                                                             
                                      
          case when old."job_name" is null then '' else '"' || replace(replace(cast(old."job_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      null,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_d_for_sym_ld_fltr_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_d_for_sym_ld_fltr_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                               
                                    values(                                                                                                                                                            
                                      'sym_load_filter',                                                                                                                                            
                                      'D',                                                                                                                                                             
                                      22,                                                                                                                                             
                                      
          case when old."load_filter_id" is null then '' else '"' || replace(replace(cast(old."load_filter_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      null,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_d_for_sym_mntr_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_d_for_sym_mntr_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                               
                                    values(                                                                                                                                                            
                                      'sym_monitor',                                                                                                                                            
                                      'D',                                                                                                                                                             
                                      23,                                                                                                                                             
                                      
          case when old."monitor_id" is null then '' else '"' || replace(replace(cast(old."monitor_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      null,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_d_for_sym_nd_grp_chnnl_wnd_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_d_for_sym_nd_grp_chnnl_wnd_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                               
                                    values(                                                                                                                                                            
                                      'sym_node_group_channel_wnd',                                                                                                                                            
                                      'D',                                                                                                                                                             
                                      17,                                                                                                                                             
                                      
          case when old."node_group_id" is null then '' else '"' || replace(replace(cast(old."node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."channel_id" is null then '' else '"' || replace(replace(cast(old."channel_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."start_time" is null then '' else '"' || to_char(old."start_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when old."end_time" is null then '' else '"' || to_char(old."end_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end,                                                                                                                                                      
                                      null,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_d_for_sym_nd_grp_lnk_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_d_for_sym_nd_grp_lnk_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                               
                                    values(                                                                                                                                                            
                                      'sym_node_group_link',                                                                                                                                            
                                      'D',                                                                                                                                                             
                                      19,                                                                                                                                             
                                      
          case when old."source_node_group_id" is null then '' else '"' || replace(replace(cast(old."source_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."target_node_group_id" is null then '' else '"' || replace(replace(cast(old."target_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      null,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_d_for_sym_nd_grp_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_d_for_sym_nd_grp_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                               
                                    values(                                                                                                                                                            
                                      'sym_node_group',                                                                                                                                            
                                      'D',                                                                                                                                                             
                                      20,                                                                                                                                             
                                      
          case when old."node_group_id" is null then '' else '"' || replace(replace(cast(old."node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      null,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_d_for_sym_nd_hst_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_d_for_sym_nd_hst_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                               
                                    values(                                                                                                                                                            
                                      'sym_node_host',                                                                                                                                            
                                      'D',                                                                                                                                                             
                                      29,                                                                                                                                             
                                      
          case when old."node_id" is null then '' else '"' || replace(replace(cast(old."node_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."host_name" is null then '' else '"' || replace(replace(cast(old."host_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      null,                                                                                                                                                   
                                      'heartbeat',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_d_for_sym_nd_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_d_for_sym_nd_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                               
                                    values(                                                                                                                                                            
                                      'sym_node',                                                                                                                                            
                                      'D',                                                                                                                                                             
                                      16,                                                                                                                                             
                                      
          case when old."node_id" is null then '' else '"' || replace(replace(cast(old."node_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      null,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_d_for_sym_nd_scrty_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_d_for_sym_nd_scrty_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                               
                                    values(                                                                                                                                                            
                                      'sym_node_security',                                                                                                                                            
                                      'D',                                                                                                                                                             
                                      21,                                                                                                                                             
                                      
          case when old."node_id" is null then '' else '"' || replace(replace(cast(old."node_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      null,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_d_for_sym_ntfctn_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_d_for_sym_ntfctn_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                               
                                    values(                                                                                                                                                            
                                      'sym_notification',                                                                                                                                            
                                      'D',                                                                                                                                                             
                                      18,                                                                                                                                             
                                      
          case when old."notification_id" is null then '' else '"' || replace(replace(cast(old."notification_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      null,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_d_for_sym_prmtr_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_d_for_sym_prmtr_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                               
                                    values(                                                                                                                                                            
                                      'sym_parameter',                                                                                                                                            
                                      'D',                                                                                                                                                             
                                      5,                                                                                                                                             
                                      
          case when old."external_id" is null then '' else '"' || replace(replace(cast(old."external_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."node_group_id" is null then '' else '"' || replace(replace(cast(old."node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."param_key" is null then '' else '"' || replace(replace(cast(old."param_key" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      null,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_d_for_sym_rtr_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_d_for_sym_rtr_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                               
                                    values(                                                                                                                                                            
                                      'sym_router',                                                                                                                                            
                                      'D',                                                                                                                                                             
                                      2,                                                                                                                                             
                                      
          case when old."router_id" is null then '' else '"' || replace(replace(cast(old."router_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      null,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_d_for_sym_tbl_rld_rqst_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_d_for_sym_tbl_rld_rqst_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                               
                                    values(                                                                                                                                                            
                                      'sym_table_reload_request',                                                                                                                                            
                                      'D',                                                                                                                                                             
                                      7,                                                                                                                                             
                                      
          case when old."target_node_id" is null then '' else '"' || replace(replace(cast(old."target_node_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."source_node_id" is null then '' else '"' || replace(replace(cast(old."source_node_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."trigger_id" is null then '' else '"' || replace(replace(cast(old."trigger_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."router_id" is null then '' else '"' || replace(replace(cast(old."router_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."create_time" is null then '' else '"' || to_char(old."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end,                                                                                                                                                      
                                      null,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_d_for_sym_trggr_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_d_for_sym_trggr_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                               
                                    values(                                                                                                                                                            
                                      'sym_trigger',                                                                                                                                            
                                      'D',                                                                                                                                                             
                                      26,                                                                                                                                             
                                      
          case when old."trigger_id" is null then '' else '"' || replace(replace(cast(old."trigger_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      null,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_d_for_sym_trggr_rtr_grplt_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_d_for_sym_trggr_rtr_grplt_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                               
                                    values(                                                                                                                                                            
                                      'sym_trigger_router_grouplet',                                                                                                                                            
                                      'D',                                                                                                                                                             
                                      28,                                                                                                                                             
                                      
          case when old."grouplet_id" is null then '' else '"' || replace(replace(cast(old."grouplet_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."trigger_id" is null then '' else '"' || replace(replace(cast(old."trigger_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."router_id" is null then '' else '"' || replace(replace(cast(old."router_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."applies_when" is null then '' else '"' || replace(replace(cast(old."applies_when" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      null,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_d_for_sym_trggr_rtr_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_d_for_sym_trggr_rtr_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                               
                                    values(                                                                                                                                                            
                                      'sym_trigger_router',                                                                                                                                            
                                      'D',                                                                                                                                                             
                                      15,                                                                                                                                             
                                      
          case when old."trigger_id" is null then '' else '"' || replace(replace(cast(old."trigger_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."router_id" is null then '' else '"' || replace(replace(cast(old."router_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      null,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_d_for_sym_trnsfrm_clmn_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_d_for_sym_trnsfrm_clmn_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                               
                                    values(                                                                                                                                                            
                                      'sym_transform_column',                                                                                                                                            
                                      'D',                                                                                                                                                             
                                      13,                                                                                                                                             
                                      
          case when old."transform_id" is null then '' else '"' || replace(replace(cast(old."transform_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."include_on" is null then '' else '"' || replace(replace(cast(old."include_on" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."target_column_name" is null then '' else '"' || replace(replace(cast(old."target_column_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      null,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_d_for_sym_trnsfrm_tbl_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_d_for_sym_trnsfrm_tbl_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                               
                                    values(                                                                                                                                                            
                                      'sym_transform_table',                                                                                                                                            
                                      'D',                                                                                                                                                             
                                      4,                                                                                                                                             
                                      
          case when old."transform_id" is null then '' else '"' || replace(replace(cast(old."transform_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."source_node_group_id" is null then '' else '"' || replace(replace(cast(old."source_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."target_node_group_id" is null then '' else '"' || replace(replace(cast(old."target_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      null,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_d_for_sym_xtnsn_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_d_for_sym_xtnsn_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                               
                                    values(                                                                                                                                                            
                                      'sym_extension',                                                                                                                                            
                                      'D',                                                                                                                                                             
                                      24,                                                                                                                                             
                                      
          case when old."extension_id" is null then '' else '"' || replace(replace(cast(old."extension_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      null,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_i_for_sym_chnnl_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_i_for_sym_chnnl_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, row_data, channel_id, transaction_id, source_node_id, external_data, create_time)                                        
                                    values(                                                                                                                                                            
                                      'sym_channel',                                                                                                                                            
                                      'I',                                                                                                                                                             
                                      27,                                                                                                                                             
                                      
          case when new."channel_id" is null then '' else '"' || replace(replace(cast(new."channel_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."processing_order" is null then '' else '"' || cast(cast(new."processing_order" as numeric) as varchar) || '"' end||','||
          case when new."max_batch_size" is null then '' else '"' || cast(cast(new."max_batch_size" as numeric) as varchar) || '"' end||','||
          case when new."max_batch_to_send" is null then '' else '"' || cast(cast(new."max_batch_to_send" as numeric) as varchar) || '"' end||','||
          case when new."max_data_to_route" is null then '' else '"' || cast(cast(new."max_data_to_route" as numeric) as varchar) || '"' end||','||
          case when new."extract_period_millis" is null then '' else '"' || cast(cast(new."extract_period_millis" as numeric) as varchar) || '"' end||','||
          case when new."enabled" is null then '' else '"' || cast(cast(new."enabled" as numeric) as varchar) || '"' end||','||
          case when new."use_old_data_to_route" is null then '' else '"' || cast(cast(new."use_old_data_to_route" as numeric) as varchar) || '"' end||','||
          case when new."use_row_data_to_route" is null then '' else '"' || cast(cast(new."use_row_data_to_route" as numeric) as varchar) || '"' end||','||
          case when new."use_pk_data_to_route" is null then '' else '"' || cast(cast(new."use_pk_data_to_route" as numeric) as varchar) || '"' end||','||
          case when new."reload_flag" is null then '' else '"' || cast(cast(new."reload_flag" as numeric) as varchar) || '"' end||','||
          case when new."file_sync_flag" is null then '' else '"' || cast(cast(new."file_sync_flag" as numeric) as varchar) || '"' end||','||
          case when new."contains_big_lob" is null then '' else '"' || cast(cast(new."contains_big_lob" as numeric) as varchar) || '"' end||','||
          case when new."batch_algorithm" is null then '' else '"' || replace(replace(cast(new."batch_algorithm" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."data_loader_type" is null then '' else '"' || replace(replace(cast(new."data_loader_type" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."description" is null then '' else '"' || replace(replace(cast(new."description" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."queue" is null then '' else '"' || replace(replace(cast(new."queue" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."max_network_kbps" is null then '' else '"' || cast(cast(new."max_network_kbps" as numeric) as varchar) || '"' end||','||
          case when new."data_event_action" is null then '' else '"' || replace(replace(cast(new."data_event_action" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end,                                                                                                                                                      
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_i_for_sym_cnflct_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_i_for_sym_cnflct_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, row_data, channel_id, transaction_id, source_node_id, external_data, create_time)                                        
                                    values(                                                                                                                                                            
                                      'sym_conflict',                                                                                                                                            
                                      'I',                                                                                                                                                             
                                      25,                                                                                                                                             
                                      
          case when new."conflict_id" is null then '' else '"' || replace(replace(cast(new."conflict_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."source_node_group_id" is null then '' else '"' || replace(replace(cast(new."source_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_node_group_id" is null then '' else '"' || replace(replace(cast(new."target_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_channel_id" is null then '' else '"' || replace(replace(cast(new."target_channel_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_catalog_name" is null then '' else '"' || replace(replace(cast(new."target_catalog_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_schema_name" is null then '' else '"' || replace(replace(cast(new."target_schema_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_table_name" is null then '' else '"' || replace(replace(cast(new."target_table_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."detect_type" is null then '' else '"' || replace(replace(cast(new."detect_type" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."detect_expression" is null then '' else '"' || replace(replace(cast(new."detect_expression" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."resolve_type" is null then '' else '"' || replace(replace(cast(new."resolve_type" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."ping_back" is null then '' else '"' || replace(replace(cast(new."ping_back" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."resolve_changes_only" is null then '' else '"' || cast(cast(new."resolve_changes_only" as numeric) as varchar) || '"' end||','||
          case when new."resolve_row_only" is null then '' else '"' || cast(cast(new."resolve_row_only" as numeric) as varchar) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end,                                                                                                                                                      
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_i_for_sym_fl_trggr_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_i_for_sym_fl_trggr_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, row_data, channel_id, transaction_id, source_node_id, external_data, create_time)                                        
                                    values(                                                                                                                                                            
                                      'sym_file_trigger',                                                                                                                                            
                                      'I',                                                                                                                                                             
                                      12,                                                                                                                                             
                                      
          case when new."trigger_id" is null then '' else '"' || replace(replace(cast(new."trigger_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."channel_id" is null then '' else '"' || replace(replace(cast(new."channel_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."reload_channel_id" is null then '' else '"' || replace(replace(cast(new."reload_channel_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."base_dir" is null then '' else '"' || replace(replace(cast(new."base_dir" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."recurse" is null then '' else '"' || cast(cast(new."recurse" as numeric) as varchar) || '"' end||','||
          case when new."includes_files" is null then '' else '"' || replace(replace(cast(new."includes_files" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."excludes_files" is null then '' else '"' || replace(replace(cast(new."excludes_files" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."sync_on_create" is null then '' else '"' || cast(cast(new."sync_on_create" as numeric) as varchar) || '"' end||','||
          case when new."sync_on_modified" is null then '' else '"' || cast(cast(new."sync_on_modified" as numeric) as varchar) || '"' end||','||
          case when new."sync_on_delete" is null then '' else '"' || cast(cast(new."sync_on_delete" as numeric) as varchar) || '"' end||','||
          case when new."sync_on_ctl_file" is null then '' else '"' || cast(cast(new."sync_on_ctl_file" as numeric) as varchar) || '"' end||','||
          case when new."delete_after_sync" is null then '' else '"' || cast(cast(new."delete_after_sync" as numeric) as varchar) || '"' end||','||
          case when new."before_copy_script" is null then '' else '"' || replace(replace(cast(new."before_copy_script" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."after_copy_script" is null then '' else '"' || replace(replace(cast(new."after_copy_script" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."description" is null then '' else '"' || replace(replace(cast(new."description" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_i_for_sym_fl_trggr_rtr_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_i_for_sym_fl_trggr_rtr_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, row_data, channel_id, transaction_id, source_node_id, external_data, create_time)                                        
                                    values(                                                                                                                                                            
                                      'sym_file_trigger_router',                                                                                                                                            
                                      'I',                                                                                                                                                             
                                      6,                                                                                                                                             
                                      
          case when new."trigger_id" is null then '' else '"' || replace(replace(cast(new."trigger_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."router_id" is null then '' else '"' || replace(replace(cast(new."router_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."enabled" is null then '' else '"' || cast(cast(new."enabled" as numeric) as varchar) || '"' end||','||
          case when new."initial_load_enabled" is null then '' else '"' || cast(cast(new."initial_load_enabled" as numeric) as varchar) || '"' end||','||
          case when new."target_base_dir" is null then '' else '"' || replace(replace(cast(new."target_base_dir" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."conflict_strategy" is null then '' else '"' || replace(replace(cast(new."conflict_strategy" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."description" is null then '' else '"' || replace(replace(cast(new."description" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_i_for_sym_grplt_lnk_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_i_for_sym_grplt_lnk_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, row_data, channel_id, transaction_id, source_node_id, external_data, create_time)                                        
                                    values(                                                                                                                                                            
                                      'sym_grouplet_link',                                                                                                                                            
                                      'I',                                                                                                                                                             
                                      9,                                                                                                                                             
                                      
          case when new."grouplet_id" is null then '' else '"' || replace(replace(cast(new."grouplet_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."external_id" is null then '' else '"' || replace(replace(cast(new."external_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end,                                                                                                                                                      
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_i_for_sym_grplt_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_i_for_sym_grplt_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, row_data, channel_id, transaction_id, source_node_id, external_data, create_time)                                        
                                    values(                                                                                                                                                            
                                      'sym_grouplet',                                                                                                                                            
                                      'I',                                                                                                                                                             
                                      10,                                                                                                                                             
                                      
          case when new."grouplet_id" is null then '' else '"' || replace(replace(cast(new."grouplet_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."grouplet_link_policy" is null then '' else '"' || replace(replace(cast(new."grouplet_link_policy" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."description" is null then '' else '"' || replace(replace(cast(new."description" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end,                                                                                                                                                      
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_i_for_sym_jb_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_i_for_sym_jb_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, row_data, channel_id, transaction_id, source_node_id, external_data, create_time)                                        
                                    values(                                                                                                                                                            
                                      'sym_job',                                                                                                                                            
                                      'I',                                                                                                                                                             
                                      14,                                                                                                                                             
                                      
          case when new."job_name" is null then '' else '"' || replace(replace(cast(new."job_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."job_type" is null then '' else '"' || replace(replace(cast(new."job_type" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."requires_registration" is null then '' else '"' || cast(cast(new."requires_registration" as numeric) as varchar) || '"' end||','||
          case when new."job_expression" is null then '' else '"' || replace(replace(cast(new."job_expression" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."description" is null then '' else '"' || replace(replace(cast(new."description" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."default_schedule" is null then '' else '"' || replace(replace(cast(new."default_schedule" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."default_auto_start" is null then '' else '"' || cast(cast(new."default_auto_start" as numeric) as varchar) || '"' end||','||
          case when new."node_group_id" is null then '' else '"' || replace(replace(cast(new."node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_by" is null then '' else '"' || replace(replace(cast(new."create_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end,                                                                                                                                                      
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_i_for_sym_ld_fltr_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_i_for_sym_ld_fltr_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, row_data, channel_id, transaction_id, source_node_id, external_data, create_time)                                        
                                    values(                                                                                                                                                            
                                      'sym_load_filter',                                                                                                                                            
                                      'I',                                                                                                                                                             
                                      22,                                                                                                                                             
                                      
          case when new."load_filter_id" is null then '' else '"' || replace(replace(cast(new."load_filter_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."load_filter_type" is null then '' else '"' || replace(replace(cast(new."load_filter_type" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."source_node_group_id" is null then '' else '"' || replace(replace(cast(new."source_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_node_group_id" is null then '' else '"' || replace(replace(cast(new."target_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_catalog_name" is null then '' else '"' || replace(replace(cast(new."target_catalog_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_schema_name" is null then '' else '"' || replace(replace(cast(new."target_schema_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_table_name" is null then '' else '"' || replace(replace(cast(new."target_table_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."filter_on_update" is null then '' else '"' || cast(cast(new."filter_on_update" as numeric) as varchar) || '"' end||','||
          case when new."filter_on_insert" is null then '' else '"' || cast(cast(new."filter_on_insert" as numeric) as varchar) || '"' end||','||
          case when new."filter_on_delete" is null then '' else '"' || cast(cast(new."filter_on_delete" as numeric) as varchar) || '"' end||','||
          case when new."before_write_script" is null then '' else '"' || replace(replace(cast(new."before_write_script" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."after_write_script" is null then '' else '"' || replace(replace(cast(new."after_write_script" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."batch_complete_script" is null then '' else '"' || replace(replace(cast(new."batch_complete_script" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."batch_commit_script" is null then '' else '"' || replace(replace(cast(new."batch_commit_script" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."batch_rollback_script" is null then '' else '"' || replace(replace(cast(new."batch_rollback_script" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."handle_error_script" is null then '' else '"' || replace(replace(cast(new."handle_error_script" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."load_filter_order" is null then '' else '"' || cast(cast(new."load_filter_order" as numeric) as varchar) || '"' end||','||
          case when new."fail_on_error" is null then '' else '"' || cast(cast(new."fail_on_error" as numeric) as varchar) || '"' end,                                                                                                                                                      
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_i_for_sym_mntr_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_i_for_sym_mntr_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, row_data, channel_id, transaction_id, source_node_id, external_data, create_time)                                        
                                    values(                                                                                                                                                            
                                      'sym_monitor',                                                                                                                                            
                                      'I',                                                                                                                                                             
                                      23,                                                                                                                                             
                                      
          case when new."monitor_id" is null then '' else '"' || replace(replace(cast(new."monitor_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."node_group_id" is null then '' else '"' || replace(replace(cast(new."node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."external_id" is null then '' else '"' || replace(replace(cast(new."external_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."type" is null then '' else '"' || replace(replace(cast(new."type" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."expression" is null then '' else '"' || replace(replace(cast(new."expression" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."threshold" is null then '' else '"' || cast(cast(new."threshold" as numeric) as varchar) || '"' end||','||
          case when new."run_period" is null then '' else '"' || cast(cast(new."run_period" as numeric) as varchar) || '"' end||','||
          case when new."run_count" is null then '' else '"' || cast(cast(new."run_count" as numeric) as varchar) || '"' end||','||
          case when new."severity_level" is null then '' else '"' || cast(cast(new."severity_level" as numeric) as varchar) || '"' end||','||
          case when new."enabled" is null then '' else '"' || cast(cast(new."enabled" as numeric) as varchar) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end,                                                                                                                                                      
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_i_for_sym_nd_grp_chnnl_wnd_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_i_for_sym_nd_grp_chnnl_wnd_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, row_data, channel_id, transaction_id, source_node_id, external_data, create_time)                                        
                                    values(                                                                                                                                                            
                                      'sym_node_group_channel_wnd',                                                                                                                                            
                                      'I',                                                                                                                                                             
                                      17,                                                                                                                                             
                                      
          case when new."node_group_id" is null then '' else '"' || replace(replace(cast(new."node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."channel_id" is null then '' else '"' || replace(replace(cast(new."channel_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."start_time" is null then '' else '"' || to_char(new."start_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."end_time" is null then '' else '"' || to_char(new."end_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."enabled" is null then '' else '"' || cast(cast(new."enabled" as numeric) as varchar) || '"' end,                                                                                                                                                      
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_i_for_sym_nd_grp_lnk_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_i_for_sym_nd_grp_lnk_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, row_data, channel_id, transaction_id, source_node_id, external_data, create_time)                                        
                                    values(                                                                                                                                                            
                                      'sym_node_group_link',                                                                                                                                            
                                      'I',                                                                                                                                                             
                                      19,                                                                                                                                             
                                      
          case when new."source_node_group_id" is null then '' else '"' || replace(replace(cast(new."source_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_node_group_id" is null then '' else '"' || replace(replace(cast(new."target_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."data_event_action" is null then '' else '"' || replace(replace(cast(new."data_event_action" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."sync_config_enabled" is null then '' else '"' || cast(cast(new."sync_config_enabled" as numeric) as varchar) || '"' end||','||
          case when new."is_reversible" is null then '' else '"' || cast(cast(new."is_reversible" as numeric) as varchar) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end,                                                                                                                                                      
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_i_for_sym_nd_grp_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_i_for_sym_nd_grp_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, row_data, channel_id, transaction_id, source_node_id, external_data, create_time)                                        
                                    values(                                                                                                                                                            
                                      'sym_node_group',                                                                                                                                            
                                      'I',                                                                                                                                                             
                                      20,                                                                                                                                             
                                      
          case when new."node_group_id" is null then '' else '"' || replace(replace(cast(new."node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."description" is null then '' else '"' || replace(replace(cast(new."description" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end,                                                                                                                                                      
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_i_for_sym_nd_hst_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_i_for_sym_nd_hst_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, row_data, channel_id, transaction_id, source_node_id, external_data, create_time)                                        
                                    values(                                                                                                                                                            
                                      'sym_node_host',                                                                                                                                            
                                      'I',                                                                                                                                                             
                                      29,                                                                                                                                             
                                      
          case when new."node_id" is null then '' else '"' || replace(replace(cast(new."node_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."host_name" is null then '' else '"' || replace(replace(cast(new."host_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."instance_id" is null then '' else '"' || replace(replace(cast(new."instance_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."ip_address" is null then '' else '"' || replace(replace(cast(new."ip_address" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."os_user" is null then '' else '"' || replace(replace(cast(new."os_user" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."os_name" is null then '' else '"' || replace(replace(cast(new."os_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."os_arch" is null then '' else '"' || replace(replace(cast(new."os_arch" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."os_version" is null then '' else '"' || replace(replace(cast(new."os_version" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."available_processors" is null then '' else '"' || cast(cast(new."available_processors" as numeric) as varchar) || '"' end||','||
          case when new."free_memory_bytes" is null then '' else '"' || cast(cast(new."free_memory_bytes" as numeric) as varchar) || '"' end||','||
          case when new."total_memory_bytes" is null then '' else '"' || cast(cast(new."total_memory_bytes" as numeric) as varchar) || '"' end||','||
          case when new."max_memory_bytes" is null then '' else '"' || cast(cast(new."max_memory_bytes" as numeric) as varchar) || '"' end||','||
          case when new."java_version" is null then '' else '"' || replace(replace(cast(new."java_version" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."java_vendor" is null then '' else '"' || replace(replace(cast(new."java_vendor" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."jdbc_version" is null then '' else '"' || replace(replace(cast(new."jdbc_version" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."symmetric_version" is null then '' else '"' || replace(replace(cast(new."symmetric_version" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."timezone_offset" is null then '' else '"' || replace(replace(cast(new."timezone_offset" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."heartbeat_time" is null then '' else '"' || to_char(new."heartbeat_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_restart_time" is null then '' else '"' || to_char(new."last_restart_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end,                                                                                                                                                      
                                      'heartbeat',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_i_for_sym_nd_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_i_for_sym_nd_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, row_data, channel_id, transaction_id, source_node_id, external_data, create_time)                                        
                                    values(                                                                                                                                                            
                                      'sym_node',                                                                                                                                            
                                      'I',                                                                                                                                                             
                                      16,                                                                                                                                             
                                      
          case when new."node_id" is null then '' else '"' || replace(replace(cast(new."node_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."node_group_id" is null then '' else '"' || replace(replace(cast(new."node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."external_id" is null then '' else '"' || replace(replace(cast(new."external_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."heartbeat_time" is null then '' else '"' || to_char(new."heartbeat_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."timezone_offset" is null then '' else '"' || replace(replace(cast(new."timezone_offset" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."sync_enabled" is null then '' else '"' || cast(cast(new."sync_enabled" as numeric) as varchar) || '"' end||','||
          case when new."sync_url" is null then '' else '"' || replace(replace(cast(new."sync_url" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."schema_version" is null then '' else '"' || replace(replace(cast(new."schema_version" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."symmetric_version" is null then '' else '"' || replace(replace(cast(new."symmetric_version" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."config_version" is null then '' else '"' || replace(replace(cast(new."config_version" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."database_type" is null then '' else '"' || replace(replace(cast(new."database_type" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."database_version" is null then '' else '"' || replace(replace(cast(new."database_version" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."batch_to_send_count" is null then '' else '"' || cast(cast(new."batch_to_send_count" as numeric) as varchar) || '"' end||','||
          case when new."batch_in_error_count" is null then '' else '"' || cast(cast(new."batch_in_error_count" as numeric) as varchar) || '"' end||','||
          case when new."created_at_node_id" is null then '' else '"' || replace(replace(cast(new."created_at_node_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."deployment_type" is null then '' else '"' || replace(replace(cast(new."deployment_type" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."deployment_sub_type" is null then '' else '"' || replace(replace(cast(new."deployment_sub_type" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_i_for_sym_nd_scrty_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_i_for_sym_nd_scrty_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, row_data, channel_id, transaction_id, source_node_id, external_data, create_time)                                        
                                    values(                                                                                                                                                            
                                      'sym_node_security',                                                                                                                                            
                                      'I',                                                                                                                                                             
                                      21,                                                                                                                                             
                                      
          case when new."node_id" is null then '' else '"' || replace(replace(cast(new."node_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."node_password" is null then '' else '"' || replace(replace(cast(new."node_password" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."registration_enabled" is null then '' else '"' || cast(cast(new."registration_enabled" as numeric) as varchar) || '"' end||','||
          case when new."registration_time" is null then '' else '"' || to_char(new."registration_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."initial_load_enabled" is null then '' else '"' || cast(cast(new."initial_load_enabled" as numeric) as varchar) || '"' end||','||
          case when new."initial_load_time" is null then '' else '"' || to_char(new."initial_load_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."initial_load_id" is null then '' else '"' || cast(cast(new."initial_load_id" as numeric) as varchar) || '"' end||','||
          case when new."initial_load_create_by" is null then '' else '"' || replace(replace(cast(new."initial_load_create_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."rev_initial_load_enabled" is null then '' else '"' || cast(cast(new."rev_initial_load_enabled" as numeric) as varchar) || '"' end||','||
          case when new."rev_initial_load_time" is null then '' else '"' || to_char(new."rev_initial_load_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."rev_initial_load_id" is null then '' else '"' || cast(cast(new."rev_initial_load_id" as numeric) as varchar) || '"' end||','||
          case when new."rev_initial_load_create_by" is null then '' else '"' || replace(replace(cast(new."rev_initial_load_create_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."created_at_node_id" is null then '' else '"' || replace(replace(cast(new."created_at_node_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_i_for_sym_ntfctn_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_i_for_sym_ntfctn_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, row_data, channel_id, transaction_id, source_node_id, external_data, create_time)                                        
                                    values(                                                                                                                                                            
                                      'sym_notification',                                                                                                                                            
                                      'I',                                                                                                                                                             
                                      18,                                                                                                                                             
                                      
          case when new."notification_id" is null then '' else '"' || replace(replace(cast(new."notification_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."node_group_id" is null then '' else '"' || replace(replace(cast(new."node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."external_id" is null then '' else '"' || replace(replace(cast(new."external_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."severity_level" is null then '' else '"' || cast(cast(new."severity_level" as numeric) as varchar) || '"' end||','||
          case when new."type" is null then '' else '"' || replace(replace(cast(new."type" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."expression" is null then '' else '"' || replace(replace(cast(new."expression" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."enabled" is null then '' else '"' || cast(cast(new."enabled" as numeric) as varchar) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end,                                                                                                                                                      
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_i_for_sym_prmtr_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_i_for_sym_prmtr_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, row_data, channel_id, transaction_id, source_node_id, external_data, create_time)                                        
                                    values(                                                                                                                                                            
                                      'sym_parameter',                                                                                                                                            
                                      'I',                                                                                                                                                             
                                      5,                                                                                                                                             
                                      
          case when new."external_id" is null then '' else '"' || replace(replace(cast(new."external_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."node_group_id" is null then '' else '"' || replace(replace(cast(new."node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."param_key" is null then '' else '"' || replace(replace(cast(new."param_key" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."param_value" is null then '' else '"' || replace(replace(cast(new."param_value" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end,                                                                                                                                                      
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_i_for_sym_rtr_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_i_for_sym_rtr_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, row_data, channel_id, transaction_id, source_node_id, external_data, create_time)                                        
                                    values(                                                                                                                                                            
                                      'sym_router',                                                                                                                                            
                                      'I',                                                                                                                                                             
                                      2,                                                                                                                                             
                                      
          case when new."router_id" is null then '' else '"' || replace(replace(cast(new."router_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_catalog_name" is null then '' else '"' || replace(replace(cast(new."target_catalog_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_schema_name" is null then '' else '"' || replace(replace(cast(new."target_schema_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_table_name" is null then '' else '"' || replace(replace(cast(new."target_table_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."source_node_group_id" is null then '' else '"' || replace(replace(cast(new."source_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_node_group_id" is null then '' else '"' || replace(replace(cast(new."target_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."router_type" is null then '' else '"' || replace(replace(cast(new."router_type" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."router_expression" is null then '' else '"' || replace(replace(cast(new."router_expression" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."sync_on_update" is null then '' else '"' || cast(cast(new."sync_on_update" as numeric) as varchar) || '"' end||','||
          case when new."sync_on_insert" is null then '' else '"' || cast(cast(new."sync_on_insert" as numeric) as varchar) || '"' end||','||
          case when new."sync_on_delete" is null then '' else '"' || cast(cast(new."sync_on_delete" as numeric) as varchar) || '"' end||','||
          case when new."use_source_catalog_schema" is null then '' else '"' || cast(cast(new."use_source_catalog_schema" as numeric) as varchar) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."description" is null then '' else '"' || replace(replace(cast(new."description" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_i_for_sym_tbl_rld_rqst_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_i_for_sym_tbl_rld_rqst_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, row_data, channel_id, transaction_id, source_node_id, external_data, create_time)                                        
                                    values(                                                                                                                                                            
                                      'sym_table_reload_request',                                                                                                                                            
                                      'I',                                                                                                                                                             
                                      7,                                                                                                                                             
                                      
          case when new."target_node_id" is null then '' else '"' || replace(replace(cast(new."target_node_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."source_node_id" is null then '' else '"' || replace(replace(cast(new."source_node_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."trigger_id" is null then '' else '"' || replace(replace(cast(new."trigger_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."router_id" is null then '' else '"' || replace(replace(cast(new."router_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."create_table" is null then '' else '"' || cast(cast(new."create_table" as numeric) as varchar) || '"' end||','||
          case when new."delete_first" is null then '' else '"' || cast(cast(new."delete_first" as numeric) as varchar) || '"' end||','||
          case when new."reload_select" is null then '' else '"' || replace(replace(cast(new."reload_select" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."before_custom_sql" is null then '' else '"' || replace(replace(cast(new."before_custom_sql" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."reload_time" is null then '' else '"' || to_char(new."reload_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."load_id" is null then '' else '"' || cast(cast(new."load_id" as numeric) as varchar) || '"' end||','||
          case when new."processed" is null then '' else '"' || cast(cast(new."processed" as numeric) as varchar) || '"' end||','||
          case when new."channel_id" is null then '' else '"' || replace(replace(cast(new."channel_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end,                                                                                                                                                      
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_i_for_sym_trggr_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_i_for_sym_trggr_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, row_data, channel_id, transaction_id, source_node_id, external_data, create_time)                                        
                                    values(                                                                                                                                                            
                                      'sym_trigger',                                                                                                                                            
                                      'I',                                                                                                                                                             
                                      26,                                                                                                                                             
                                      
          case when new."trigger_id" is null then '' else '"' || replace(replace(cast(new."trigger_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."source_catalog_name" is null then '' else '"' || replace(replace(cast(new."source_catalog_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."source_schema_name" is null then '' else '"' || replace(replace(cast(new."source_schema_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."source_table_name" is null then '' else '"' || replace(replace(cast(new."source_table_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."channel_id" is null then '' else '"' || replace(replace(cast(new."channel_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."reload_channel_id" is null then '' else '"' || replace(replace(cast(new."reload_channel_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."sync_on_update" is null then '' else '"' || cast(cast(new."sync_on_update" as numeric) as varchar) || '"' end||','||
          case when new."sync_on_insert" is null then '' else '"' || cast(cast(new."sync_on_insert" as numeric) as varchar) || '"' end||','||
          case when new."sync_on_delete" is null then '' else '"' || cast(cast(new."sync_on_delete" as numeric) as varchar) || '"' end||','||
          case when new."sync_on_incoming_batch" is null then '' else '"' || cast(cast(new."sync_on_incoming_batch" as numeric) as varchar) || '"' end||','||
          case when new."name_for_update_trigger" is null then '' else '"' || replace(replace(cast(new."name_for_update_trigger" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."name_for_insert_trigger" is null then '' else '"' || replace(replace(cast(new."name_for_insert_trigger" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."name_for_delete_trigger" is null then '' else '"' || replace(replace(cast(new."name_for_delete_trigger" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."sync_on_update_condition" is null then '' else '"' || replace(replace(cast(new."sync_on_update_condition" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."sync_on_insert_condition" is null then '' else '"' || replace(replace(cast(new."sync_on_insert_condition" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."sync_on_delete_condition" is null then '' else '"' || replace(replace(cast(new."sync_on_delete_condition" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."custom_before_update_text" is null then '' else '"' || replace(replace(cast(new."custom_before_update_text" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."custom_before_insert_text" is null then '' else '"' || replace(replace(cast(new."custom_before_insert_text" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."custom_before_delete_text" is null then '' else '"' || replace(replace(cast(new."custom_before_delete_text" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."custom_on_update_text" is null then '' else '"' || replace(replace(cast(new."custom_on_update_text" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."custom_on_insert_text" is null then '' else '"' || replace(replace(cast(new."custom_on_insert_text" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."custom_on_delete_text" is null then '' else '"' || replace(replace(cast(new."custom_on_delete_text" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."external_select" is null then '' else '"' || replace(replace(cast(new."external_select" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."tx_id_expression" is null then '' else '"' || replace(replace(cast(new."tx_id_expression" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."channel_expression" is null then '' else '"' || replace(replace(cast(new."channel_expression" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."excluded_column_names" is null then '' else '"' || replace(replace(cast(new."excluded_column_names" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."included_column_names" is null then '' else '"' || replace(replace(cast(new."included_column_names" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."sync_key_names" is null then '' else '"' || replace(replace(cast(new."sync_key_names" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."use_stream_lobs" is null then '' else '"' || cast(cast(new."use_stream_lobs" as numeric) as varchar) || '"' end||','||
          case when new."use_capture_lobs" is null then '' else '"' || cast(cast(new."use_capture_lobs" as numeric) as varchar) || '"' end||','||
          case when new."use_capture_old_data" is null then '' else '"' || cast(cast(new."use_capture_old_data" as numeric) as varchar) || '"' end||','||
          case when new."use_handle_key_updates" is null then '' else '"' || cast(cast(new."use_handle_key_updates" as numeric) as varchar) || '"' end||','||
          case when new."stream_row" is null then '' else '"' || cast(cast(new."stream_row" as numeric) as varchar) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."description" is null then '' else '"' || replace(replace(cast(new."description" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_i_for_sym_trggr_rtr_grplt_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_i_for_sym_trggr_rtr_grplt_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, row_data, channel_id, transaction_id, source_node_id, external_data, create_time)                                        
                                    values(                                                                                                                                                            
                                      'sym_trigger_router_grouplet',                                                                                                                                            
                                      'I',                                                                                                                                                             
                                      28,                                                                                                                                             
                                      
          case when new."grouplet_id" is null then '' else '"' || replace(replace(cast(new."grouplet_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."trigger_id" is null then '' else '"' || replace(replace(cast(new."trigger_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."router_id" is null then '' else '"' || replace(replace(cast(new."router_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."applies_when" is null then '' else '"' || replace(replace(cast(new."applies_when" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end,                                                                                                                                                      
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_i_for_sym_trggr_rtr_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_i_for_sym_trggr_rtr_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, row_data, channel_id, transaction_id, source_node_id, external_data, create_time)                                        
                                    values(                                                                                                                                                            
                                      'sym_trigger_router',                                                                                                                                            
                                      'I',                                                                                                                                                             
                                      15,                                                                                                                                             
                                      
          case when new."trigger_id" is null then '' else '"' || replace(replace(cast(new."trigger_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."router_id" is null then '' else '"' || replace(replace(cast(new."router_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."enabled" is null then '' else '"' || cast(cast(new."enabled" as numeric) as varchar) || '"' end||','||
          case when new."initial_load_order" is null then '' else '"' || cast(cast(new."initial_load_order" as numeric) as varchar) || '"' end||','||
          case when new."initial_load_select" is null then '' else '"' || replace(replace(cast(new."initial_load_select" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."initial_load_delete_stmt" is null then '' else '"' || replace(replace(cast(new."initial_load_delete_stmt" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."ping_back_enabled" is null then '' else '"' || cast(cast(new."ping_back_enabled" as numeric) as varchar) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."description" is null then '' else '"' || replace(replace(cast(new."description" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_i_for_sym_trnsfrm_clmn_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_i_for_sym_trnsfrm_clmn_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, row_data, channel_id, transaction_id, source_node_id, external_data, create_time)                                        
                                    values(                                                                                                                                                            
                                      'sym_transform_column',                                                                                                                                            
                                      'I',                                                                                                                                                             
                                      13,                                                                                                                                             
                                      
          case when new."transform_id" is null then '' else '"' || replace(replace(cast(new."transform_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."include_on" is null then '' else '"' || replace(replace(cast(new."include_on" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_column_name" is null then '' else '"' || replace(replace(cast(new."target_column_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."source_column_name" is null then '' else '"' || replace(replace(cast(new."source_column_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."pk" is null then '' else '"' || cast(cast(new."pk" as numeric) as varchar) || '"' end||','||
          case when new."transform_type" is null then '' else '"' || replace(replace(cast(new."transform_type" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."transform_expression" is null then '' else '"' || replace(replace(cast(new."transform_expression" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."transform_order" is null then '' else '"' || cast(cast(new."transform_order" as numeric) as varchar) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."description" is null then '' else '"' || replace(replace(cast(new."description" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_i_for_sym_trnsfrm_tbl_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_i_for_sym_trnsfrm_tbl_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, row_data, channel_id, transaction_id, source_node_id, external_data, create_time)                                        
                                    values(                                                                                                                                                            
                                      'sym_transform_table',                                                                                                                                            
                                      'I',                                                                                                                                                             
                                      4,                                                                                                                                             
                                      
          case when new."transform_id" is null then '' else '"' || replace(replace(cast(new."transform_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."source_node_group_id" is null then '' else '"' || replace(replace(cast(new."source_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_node_group_id" is null then '' else '"' || replace(replace(cast(new."target_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."transform_point" is null then '' else '"' || replace(replace(cast(new."transform_point" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."source_catalog_name" is null then '' else '"' || replace(replace(cast(new."source_catalog_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."source_schema_name" is null then '' else '"' || replace(replace(cast(new."source_schema_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."source_table_name" is null then '' else '"' || replace(replace(cast(new."source_table_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_catalog_name" is null then '' else '"' || replace(replace(cast(new."target_catalog_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_schema_name" is null then '' else '"' || replace(replace(cast(new."target_schema_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_table_name" is null then '' else '"' || replace(replace(cast(new."target_table_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."update_first" is null then '' else '"' || cast(cast(new."update_first" as numeric) as varchar) || '"' end||','||
          case when new."update_action" is null then '' else '"' || replace(replace(cast(new."update_action" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."delete_action" is null then '' else '"' || replace(replace(cast(new."delete_action" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."transform_order" is null then '' else '"' || cast(cast(new."transform_order" as numeric) as varchar) || '"' end||','||
          case when new."column_policy" is null then '' else '"' || replace(replace(cast(new."column_policy" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."description" is null then '' else '"' || replace(replace(cast(new."description" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_i_for_sym_xtnsn_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_i_for_sym_xtnsn_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                begin                                                                                                                                                                  
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, row_data, channel_id, transaction_id, source_node_id, external_data, create_time)                                        
                                    values(                                                                                                                                                            
                                      'sym_extension',                                                                                                                                            
                                      'I',                                                                                                                                                             
                                      24,                                                                                                                                             
                                      
          case when new."extension_id" is null then '' else '"' || replace(replace(cast(new."extension_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."extension_type" is null then '' else '"' || replace(replace(cast(new."extension_type" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."interface_name" is null then '' else '"' || replace(replace(cast(new."interface_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."node_group_id" is null then '' else '"' || replace(replace(cast(new."node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."enabled" is null then '' else '"' || cast(cast(new."enabled" as numeric) as varchar) || '"' end||','||
          case when new."extension_order" is null then '' else '"' || cast(cast(new."extension_order" as numeric) as varchar) || '"' end||','||
          case when new."extension_text" is null then '' else '"' || replace(replace(cast(new."extension_text" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end,                                                                                                                                                      
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_u_for_sym_chnnl_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_u_for_sym_chnnl_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                declare var_row_data text; 
                                declare var_old_data text; 
                                begin
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    var_row_data := 
          case when new."channel_id" is null then '' else '"' || replace(replace(cast(new."channel_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."processing_order" is null then '' else '"' || cast(cast(new."processing_order" as numeric) as varchar) || '"' end||','||
          case when new."max_batch_size" is null then '' else '"' || cast(cast(new."max_batch_size" as numeric) as varchar) || '"' end||','||
          case when new."max_batch_to_send" is null then '' else '"' || cast(cast(new."max_batch_to_send" as numeric) as varchar) || '"' end||','||
          case when new."max_data_to_route" is null then '' else '"' || cast(cast(new."max_data_to_route" as numeric) as varchar) || '"' end||','||
          case when new."extract_period_millis" is null then '' else '"' || cast(cast(new."extract_period_millis" as numeric) as varchar) || '"' end||','||
          case when new."enabled" is null then '' else '"' || cast(cast(new."enabled" as numeric) as varchar) || '"' end||','||
          case when new."use_old_data_to_route" is null then '' else '"' || cast(cast(new."use_old_data_to_route" as numeric) as varchar) || '"' end||','||
          case when new."use_row_data_to_route" is null then '' else '"' || cast(cast(new."use_row_data_to_route" as numeric) as varchar) || '"' end||','||
          case when new."use_pk_data_to_route" is null then '' else '"' || cast(cast(new."use_pk_data_to_route" as numeric) as varchar) || '"' end||','||
          case when new."reload_flag" is null then '' else '"' || cast(cast(new."reload_flag" as numeric) as varchar) || '"' end||','||
          case when new."file_sync_flag" is null then '' else '"' || cast(cast(new."file_sync_flag" as numeric) as varchar) || '"' end||','||
          case when new."contains_big_lob" is null then '' else '"' || cast(cast(new."contains_big_lob" as numeric) as varchar) || '"' end||','||
          case when new."batch_algorithm" is null then '' else '"' || replace(replace(cast(new."batch_algorithm" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."data_loader_type" is null then '' else '"' || replace(replace(cast(new."data_loader_type" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."description" is null then '' else '"' || replace(replace(cast(new."description" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."queue" is null then '' else '"' || replace(replace(cast(new."queue" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."max_network_kbps" is null then '' else '"' || cast(cast(new."max_network_kbps" as numeric) as varchar) || '"' end||','||
          case when new."data_event_action" is null then '' else '"' || replace(replace(cast(new."data_event_action" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end; 
                                    var_old_data := null; 
                                    if 1=1 then 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, row_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                     
                                    values(                                                                                                                                                            
                                      'sym_channel',                                                                                                                                            
                                      'U',                                                                                                                                                             
                                      27,                                                                                                                                             
                                      
          case when old."channel_id" is null then '' else '"' || replace(replace(cast(old."channel_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      var_row_data,                                                                                                                                                      
                                      var_old_data,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_u_for_sym_cnflct_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_u_for_sym_cnflct_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                declare var_row_data text; 
                                declare var_old_data text; 
                                begin
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    var_row_data := 
          case when new."conflict_id" is null then '' else '"' || replace(replace(cast(new."conflict_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."source_node_group_id" is null then '' else '"' || replace(replace(cast(new."source_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_node_group_id" is null then '' else '"' || replace(replace(cast(new."target_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_channel_id" is null then '' else '"' || replace(replace(cast(new."target_channel_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_catalog_name" is null then '' else '"' || replace(replace(cast(new."target_catalog_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_schema_name" is null then '' else '"' || replace(replace(cast(new."target_schema_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_table_name" is null then '' else '"' || replace(replace(cast(new."target_table_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."detect_type" is null then '' else '"' || replace(replace(cast(new."detect_type" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."detect_expression" is null then '' else '"' || replace(replace(cast(new."detect_expression" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."resolve_type" is null then '' else '"' || replace(replace(cast(new."resolve_type" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."ping_back" is null then '' else '"' || replace(replace(cast(new."ping_back" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."resolve_changes_only" is null then '' else '"' || cast(cast(new."resolve_changes_only" as numeric) as varchar) || '"' end||','||
          case when new."resolve_row_only" is null then '' else '"' || cast(cast(new."resolve_row_only" as numeric) as varchar) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end; 
                                    var_old_data := null; 
                                    if 1=1 then 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, row_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                     
                                    values(                                                                                                                                                            
                                      'sym_conflict',                                                                                                                                            
                                      'U',                                                                                                                                                             
                                      25,                                                                                                                                             
                                      
          case when old."conflict_id" is null then '' else '"' || replace(replace(cast(old."conflict_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      var_row_data,                                                                                                                                                      
                                      var_old_data,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_u_for_sym_fl_trggr_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_u_for_sym_fl_trggr_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                declare var_row_data text; 
                                declare var_old_data text; 
                                begin
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    var_row_data := 
          case when new."trigger_id" is null then '' else '"' || replace(replace(cast(new."trigger_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."channel_id" is null then '' else '"' || replace(replace(cast(new."channel_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."reload_channel_id" is null then '' else '"' || replace(replace(cast(new."reload_channel_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."base_dir" is null then '' else '"' || replace(replace(cast(new."base_dir" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."recurse" is null then '' else '"' || cast(cast(new."recurse" as numeric) as varchar) || '"' end||','||
          case when new."includes_files" is null then '' else '"' || replace(replace(cast(new."includes_files" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."excludes_files" is null then '' else '"' || replace(replace(cast(new."excludes_files" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."sync_on_create" is null then '' else '"' || cast(cast(new."sync_on_create" as numeric) as varchar) || '"' end||','||
          case when new."sync_on_modified" is null then '' else '"' || cast(cast(new."sync_on_modified" as numeric) as varchar) || '"' end||','||
          case when new."sync_on_delete" is null then '' else '"' || cast(cast(new."sync_on_delete" as numeric) as varchar) || '"' end||','||
          case when new."sync_on_ctl_file" is null then '' else '"' || cast(cast(new."sync_on_ctl_file" as numeric) as varchar) || '"' end||','||
          case when new."delete_after_sync" is null then '' else '"' || cast(cast(new."delete_after_sync" as numeric) as varchar) || '"' end||','||
          case when new."before_copy_script" is null then '' else '"' || replace(replace(cast(new."before_copy_script" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."after_copy_script" is null then '' else '"' || replace(replace(cast(new."after_copy_script" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."description" is null then '' else '"' || replace(replace(cast(new."description" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end; 
                                    var_old_data := null; 
                                    if 1=1 then 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, row_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                     
                                    values(                                                                                                                                                            
                                      'sym_file_trigger',                                                                                                                                            
                                      'U',                                                                                                                                                             
                                      12,                                                                                                                                             
                                      
          case when old."trigger_id" is null then '' else '"' || replace(replace(cast(old."trigger_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      var_row_data,                                                                                                                                                      
                                      var_old_data,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_u_for_sym_fl_trggr_rtr_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_u_for_sym_fl_trggr_rtr_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                declare var_row_data text; 
                                declare var_old_data text; 
                                begin
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    var_row_data := 
          case when new."trigger_id" is null then '' else '"' || replace(replace(cast(new."trigger_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."router_id" is null then '' else '"' || replace(replace(cast(new."router_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."enabled" is null then '' else '"' || cast(cast(new."enabled" as numeric) as varchar) || '"' end||','||
          case when new."initial_load_enabled" is null then '' else '"' || cast(cast(new."initial_load_enabled" as numeric) as varchar) || '"' end||','||
          case when new."target_base_dir" is null then '' else '"' || replace(replace(cast(new."target_base_dir" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."conflict_strategy" is null then '' else '"' || replace(replace(cast(new."conflict_strategy" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."description" is null then '' else '"' || replace(replace(cast(new."description" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end; 
                                    var_old_data := null; 
                                    if 1=1 then 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, row_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                     
                                    values(                                                                                                                                                            
                                      'sym_file_trigger_router',                                                                                                                                            
                                      'U',                                                                                                                                                             
                                      6,                                                                                                                                             
                                      
          case when old."trigger_id" is null then '' else '"' || replace(replace(cast(old."trigger_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."router_id" is null then '' else '"' || replace(replace(cast(old."router_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      var_row_data,                                                                                                                                                      
                                      var_old_data,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_u_for_sym_grplt_lnk_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_u_for_sym_grplt_lnk_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                declare var_row_data text; 
                                declare var_old_data text; 
                                begin
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    var_row_data := 
          case when new."grouplet_id" is null then '' else '"' || replace(replace(cast(new."grouplet_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."external_id" is null then '' else '"' || replace(replace(cast(new."external_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end; 
                                    var_old_data := null; 
                                    if 1=1 then 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, row_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                     
                                    values(                                                                                                                                                            
                                      'sym_grouplet_link',                                                                                                                                            
                                      'U',                                                                                                                                                             
                                      9,                                                                                                                                             
                                      
          case when old."grouplet_id" is null then '' else '"' || replace(replace(cast(old."grouplet_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."external_id" is null then '' else '"' || replace(replace(cast(old."external_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      var_row_data,                                                                                                                                                      
                                      var_old_data,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_u_for_sym_grplt_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_u_for_sym_grplt_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                declare var_row_data text; 
                                declare var_old_data text; 
                                begin
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    var_row_data := 
          case when new."grouplet_id" is null then '' else '"' || replace(replace(cast(new."grouplet_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."grouplet_link_policy" is null then '' else '"' || replace(replace(cast(new."grouplet_link_policy" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."description" is null then '' else '"' || replace(replace(cast(new."description" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end; 
                                    var_old_data := null; 
                                    if 1=1 then 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, row_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                     
                                    values(                                                                                                                                                            
                                      'sym_grouplet',                                                                                                                                            
                                      'U',                                                                                                                                                             
                                      10,                                                                                                                                             
                                      
          case when old."grouplet_id" is null then '' else '"' || replace(replace(cast(old."grouplet_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      var_row_data,                                                                                                                                                      
                                      var_old_data,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_u_for_sym_jb_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_u_for_sym_jb_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                declare var_row_data text; 
                                declare var_old_data text; 
                                begin
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    var_row_data := 
          case when new."job_name" is null then '' else '"' || replace(replace(cast(new."job_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."job_type" is null then '' else '"' || replace(replace(cast(new."job_type" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."requires_registration" is null then '' else '"' || cast(cast(new."requires_registration" as numeric) as varchar) || '"' end||','||
          case when new."job_expression" is null then '' else '"' || replace(replace(cast(new."job_expression" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."description" is null then '' else '"' || replace(replace(cast(new."description" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."default_schedule" is null then '' else '"' || replace(replace(cast(new."default_schedule" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."default_auto_start" is null then '' else '"' || cast(cast(new."default_auto_start" as numeric) as varchar) || '"' end||','||
          case when new."node_group_id" is null then '' else '"' || replace(replace(cast(new."node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_by" is null then '' else '"' || replace(replace(cast(new."create_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end; 
                                    var_old_data := null; 
                                    if 1=1 then 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, row_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                     
                                    values(                                                                                                                                                            
                                      'sym_job',                                                                                                                                            
                                      'U',                                                                                                                                                             
                                      14,                                                                                                                                             
                                      
          case when old."job_name" is null then '' else '"' || replace(replace(cast(old."job_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      var_row_data,                                                                                                                                                      
                                      var_old_data,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_u_for_sym_ld_fltr_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_u_for_sym_ld_fltr_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                declare var_row_data text; 
                                declare var_old_data text; 
                                begin
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    var_row_data := 
          case when new."load_filter_id" is null then '' else '"' || replace(replace(cast(new."load_filter_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."load_filter_type" is null then '' else '"' || replace(replace(cast(new."load_filter_type" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."source_node_group_id" is null then '' else '"' || replace(replace(cast(new."source_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_node_group_id" is null then '' else '"' || replace(replace(cast(new."target_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_catalog_name" is null then '' else '"' || replace(replace(cast(new."target_catalog_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_schema_name" is null then '' else '"' || replace(replace(cast(new."target_schema_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_table_name" is null then '' else '"' || replace(replace(cast(new."target_table_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."filter_on_update" is null then '' else '"' || cast(cast(new."filter_on_update" as numeric) as varchar) || '"' end||','||
          case when new."filter_on_insert" is null then '' else '"' || cast(cast(new."filter_on_insert" as numeric) as varchar) || '"' end||','||
          case when new."filter_on_delete" is null then '' else '"' || cast(cast(new."filter_on_delete" as numeric) as varchar) || '"' end||','||
          case when new."before_write_script" is null then '' else '"' || replace(replace(cast(new."before_write_script" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."after_write_script" is null then '' else '"' || replace(replace(cast(new."after_write_script" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."batch_complete_script" is null then '' else '"' || replace(replace(cast(new."batch_complete_script" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."batch_commit_script" is null then '' else '"' || replace(replace(cast(new."batch_commit_script" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."batch_rollback_script" is null then '' else '"' || replace(replace(cast(new."batch_rollback_script" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."handle_error_script" is null then '' else '"' || replace(replace(cast(new."handle_error_script" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."load_filter_order" is null then '' else '"' || cast(cast(new."load_filter_order" as numeric) as varchar) || '"' end||','||
          case when new."fail_on_error" is null then '' else '"' || cast(cast(new."fail_on_error" as numeric) as varchar) || '"' end; 
                                    var_old_data := null; 
                                    if 1=1 then 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, row_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                     
                                    values(                                                                                                                                                            
                                      'sym_load_filter',                                                                                                                                            
                                      'U',                                                                                                                                                             
                                      22,                                                                                                                                             
                                      
          case when old."load_filter_id" is null then '' else '"' || replace(replace(cast(old."load_filter_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      var_row_data,                                                                                                                                                      
                                      var_old_data,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_u_for_sym_mntr_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_u_for_sym_mntr_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                declare var_row_data text; 
                                declare var_old_data text; 
                                begin
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    var_row_data := 
          case when new."monitor_id" is null then '' else '"' || replace(replace(cast(new."monitor_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."node_group_id" is null then '' else '"' || replace(replace(cast(new."node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."external_id" is null then '' else '"' || replace(replace(cast(new."external_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."type" is null then '' else '"' || replace(replace(cast(new."type" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."expression" is null then '' else '"' || replace(replace(cast(new."expression" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."threshold" is null then '' else '"' || cast(cast(new."threshold" as numeric) as varchar) || '"' end||','||
          case when new."run_period" is null then '' else '"' || cast(cast(new."run_period" as numeric) as varchar) || '"' end||','||
          case when new."run_count" is null then '' else '"' || cast(cast(new."run_count" as numeric) as varchar) || '"' end||','||
          case when new."severity_level" is null then '' else '"' || cast(cast(new."severity_level" as numeric) as varchar) || '"' end||','||
          case when new."enabled" is null then '' else '"' || cast(cast(new."enabled" as numeric) as varchar) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end; 
                                    var_old_data := null; 
                                    if 1=1 then 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, row_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                     
                                    values(                                                                                                                                                            
                                      'sym_monitor',                                                                                                                                            
                                      'U',                                                                                                                                                             
                                      23,                                                                                                                                             
                                      
          case when old."monitor_id" is null then '' else '"' || replace(replace(cast(old."monitor_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      var_row_data,                                                                                                                                                      
                                      var_old_data,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_u_for_sym_nd_grp_chnnl_wnd_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_u_for_sym_nd_grp_chnnl_wnd_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                declare var_row_data text; 
                                declare var_old_data text; 
                                begin
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    var_row_data := 
          case when new."node_group_id" is null then '' else '"' || replace(replace(cast(new."node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."channel_id" is null then '' else '"' || replace(replace(cast(new."channel_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."start_time" is null then '' else '"' || to_char(new."start_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."end_time" is null then '' else '"' || to_char(new."end_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."enabled" is null then '' else '"' || cast(cast(new."enabled" as numeric) as varchar) || '"' end; 
                                    var_old_data := null; 
                                    if 1=1 then 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, row_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                     
                                    values(                                                                                                                                                            
                                      'sym_node_group_channel_wnd',                                                                                                                                            
                                      'U',                                                                                                                                                             
                                      17,                                                                                                                                             
                                      
          case when old."node_group_id" is null then '' else '"' || replace(replace(cast(old."node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."channel_id" is null then '' else '"' || replace(replace(cast(old."channel_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."start_time" is null then '' else '"' || to_char(old."start_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when old."end_time" is null then '' else '"' || to_char(old."end_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end,                                                                                                                                                      
                                      var_row_data,                                                                                                                                                      
                                      var_old_data,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_u_for_sym_nd_grp_lnk_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_u_for_sym_nd_grp_lnk_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                declare var_row_data text; 
                                declare var_old_data text; 
                                begin
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    var_row_data := 
          case when new."source_node_group_id" is null then '' else '"' || replace(replace(cast(new."source_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_node_group_id" is null then '' else '"' || replace(replace(cast(new."target_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."data_event_action" is null then '' else '"' || replace(replace(cast(new."data_event_action" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."sync_config_enabled" is null then '' else '"' || cast(cast(new."sync_config_enabled" as numeric) as varchar) || '"' end||','||
          case when new."is_reversible" is null then '' else '"' || cast(cast(new."is_reversible" as numeric) as varchar) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end; 
                                    var_old_data := null; 
                                    if 1=1 then 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, row_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                     
                                    values(                                                                                                                                                            
                                      'sym_node_group_link',                                                                                                                                            
                                      'U',                                                                                                                                                             
                                      19,                                                                                                                                             
                                      
          case when old."source_node_group_id" is null then '' else '"' || replace(replace(cast(old."source_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."target_node_group_id" is null then '' else '"' || replace(replace(cast(old."target_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      var_row_data,                                                                                                                                                      
                                      var_old_data,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_u_for_sym_nd_grp_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_u_for_sym_nd_grp_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                declare var_row_data text; 
                                declare var_old_data text; 
                                begin
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    var_row_data := 
          case when new."node_group_id" is null then '' else '"' || replace(replace(cast(new."node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."description" is null then '' else '"' || replace(replace(cast(new."description" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end; 
                                    var_old_data := null; 
                                    if 1=1 then 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, row_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                     
                                    values(                                                                                                                                                            
                                      'sym_node_group',                                                                                                                                            
                                      'U',                                                                                                                                                             
                                      20,                                                                                                                                             
                                      
          case when old."node_group_id" is null then '' else '"' || replace(replace(cast(old."node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      var_row_data,                                                                                                                                                      
                                      var_old_data,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_u_for_sym_nd_hst_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_u_for_sym_nd_hst_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                declare var_row_data text; 
                                declare var_old_data text; 
                                begin
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    var_row_data := 
          case when new."node_id" is null then '' else '"' || replace(replace(cast(new."node_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."host_name" is null then '' else '"' || replace(replace(cast(new."host_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."instance_id" is null then '' else '"' || replace(replace(cast(new."instance_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."ip_address" is null then '' else '"' || replace(replace(cast(new."ip_address" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."os_user" is null then '' else '"' || replace(replace(cast(new."os_user" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."os_name" is null then '' else '"' || replace(replace(cast(new."os_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."os_arch" is null then '' else '"' || replace(replace(cast(new."os_arch" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."os_version" is null then '' else '"' || replace(replace(cast(new."os_version" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."available_processors" is null then '' else '"' || cast(cast(new."available_processors" as numeric) as varchar) || '"' end||','||
          case when new."free_memory_bytes" is null then '' else '"' || cast(cast(new."free_memory_bytes" as numeric) as varchar) || '"' end||','||
          case when new."total_memory_bytes" is null then '' else '"' || cast(cast(new."total_memory_bytes" as numeric) as varchar) || '"' end||','||
          case when new."max_memory_bytes" is null then '' else '"' || cast(cast(new."max_memory_bytes" as numeric) as varchar) || '"' end||','||
          case when new."java_version" is null then '' else '"' || replace(replace(cast(new."java_version" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."java_vendor" is null then '' else '"' || replace(replace(cast(new."java_vendor" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."jdbc_version" is null then '' else '"' || replace(replace(cast(new."jdbc_version" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."symmetric_version" is null then '' else '"' || replace(replace(cast(new."symmetric_version" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."timezone_offset" is null then '' else '"' || replace(replace(cast(new."timezone_offset" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."heartbeat_time" is null then '' else '"' || to_char(new."heartbeat_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_restart_time" is null then '' else '"' || to_char(new."last_restart_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end; 
                                    var_old_data := null; 
                                    if 1=1 then 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, row_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                     
                                    values(                                                                                                                                                            
                                      'sym_node_host',                                                                                                                                            
                                      'U',                                                                                                                                                             
                                      29,                                                                                                                                             
                                      
          case when old."node_id" is null then '' else '"' || replace(replace(cast(old."node_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."host_name" is null then '' else '"' || replace(replace(cast(old."host_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      var_row_data,                                                                                                                                                      
                                      var_old_data,                                                                                                                                                   
                                      'heartbeat',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_u_for_sym_nd_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_u_for_sym_nd_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                declare var_row_data text; 
                                declare var_old_data text; 
                                begin
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    var_row_data := 
          case when new."node_id" is null then '' else '"' || replace(replace(cast(new."node_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."node_group_id" is null then '' else '"' || replace(replace(cast(new."node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."external_id" is null then '' else '"' || replace(replace(cast(new."external_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."heartbeat_time" is null then '' else '"' || to_char(new."heartbeat_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."timezone_offset" is null then '' else '"' || replace(replace(cast(new."timezone_offset" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."sync_enabled" is null then '' else '"' || cast(cast(new."sync_enabled" as numeric) as varchar) || '"' end||','||
          case when new."sync_url" is null then '' else '"' || replace(replace(cast(new."sync_url" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."schema_version" is null then '' else '"' || replace(replace(cast(new."schema_version" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."symmetric_version" is null then '' else '"' || replace(replace(cast(new."symmetric_version" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."config_version" is null then '' else '"' || replace(replace(cast(new."config_version" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."database_type" is null then '' else '"' || replace(replace(cast(new."database_type" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."database_version" is null then '' else '"' || replace(replace(cast(new."database_version" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."batch_to_send_count" is null then '' else '"' || cast(cast(new."batch_to_send_count" as numeric) as varchar) || '"' end||','||
          case when new."batch_in_error_count" is null then '' else '"' || cast(cast(new."batch_in_error_count" as numeric) as varchar) || '"' end||','||
          case when new."created_at_node_id" is null then '' else '"' || replace(replace(cast(new."created_at_node_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."deployment_type" is null then '' else '"' || replace(replace(cast(new."deployment_type" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."deployment_sub_type" is null then '' else '"' || replace(replace(cast(new."deployment_sub_type" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end; 
                                    var_old_data := null; 
                                    if 1=1 then 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, row_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                     
                                    values(                                                                                                                                                            
                                      'sym_node',                                                                                                                                            
                                      'U',                                                                                                                                                             
                                      16,                                                                                                                                             
                                      
          case when old."node_id" is null then '' else '"' || replace(replace(cast(old."node_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      var_row_data,                                                                                                                                                      
                                      var_old_data,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_u_for_sym_nd_scrty_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_u_for_sym_nd_scrty_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                declare var_row_data text; 
                                declare var_old_data text; 
                                begin
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    var_row_data := 
          case when new."node_id" is null then '' else '"' || replace(replace(cast(new."node_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."node_password" is null then '' else '"' || replace(replace(cast(new."node_password" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."registration_enabled" is null then '' else '"' || cast(cast(new."registration_enabled" as numeric) as varchar) || '"' end||','||
          case when new."registration_time" is null then '' else '"' || to_char(new."registration_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."initial_load_enabled" is null then '' else '"' || cast(cast(new."initial_load_enabled" as numeric) as varchar) || '"' end||','||
          case when new."initial_load_time" is null then '' else '"' || to_char(new."initial_load_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."initial_load_id" is null then '' else '"' || cast(cast(new."initial_load_id" as numeric) as varchar) || '"' end||','||
          case when new."initial_load_create_by" is null then '' else '"' || replace(replace(cast(new."initial_load_create_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."rev_initial_load_enabled" is null then '' else '"' || cast(cast(new."rev_initial_load_enabled" as numeric) as varchar) || '"' end||','||
          case when new."rev_initial_load_time" is null then '' else '"' || to_char(new."rev_initial_load_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."rev_initial_load_id" is null then '' else '"' || cast(cast(new."rev_initial_load_id" as numeric) as varchar) || '"' end||','||
          case when new."rev_initial_load_create_by" is null then '' else '"' || replace(replace(cast(new."rev_initial_load_create_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."created_at_node_id" is null then '' else '"' || replace(replace(cast(new."created_at_node_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end; 
                                    var_old_data := null; 
                                    if 1=1 then 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, row_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                     
                                    values(                                                                                                                                                            
                                      'sym_node_security',                                                                                                                                            
                                      'U',                                                                                                                                                             
                                      21,                                                                                                                                             
                                      
          case when old."node_id" is null then '' else '"' || replace(replace(cast(old."node_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      var_row_data,                                                                                                                                                      
                                      var_old_data,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_u_for_sym_ntfctn_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_u_for_sym_ntfctn_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                declare var_row_data text; 
                                declare var_old_data text; 
                                begin
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    var_row_data := 
          case when new."notification_id" is null then '' else '"' || replace(replace(cast(new."notification_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."node_group_id" is null then '' else '"' || replace(replace(cast(new."node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."external_id" is null then '' else '"' || replace(replace(cast(new."external_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."severity_level" is null then '' else '"' || cast(cast(new."severity_level" as numeric) as varchar) || '"' end||','||
          case when new."type" is null then '' else '"' || replace(replace(cast(new."type" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."expression" is null then '' else '"' || replace(replace(cast(new."expression" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."enabled" is null then '' else '"' || cast(cast(new."enabled" as numeric) as varchar) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end; 
                                    var_old_data := null; 
                                    if 1=1 then 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, row_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                     
                                    values(                                                                                                                                                            
                                      'sym_notification',                                                                                                                                            
                                      'U',                                                                                                                                                             
                                      18,                                                                                                                                             
                                      
          case when old."notification_id" is null then '' else '"' || replace(replace(cast(old."notification_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      var_row_data,                                                                                                                                                      
                                      var_old_data,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_u_for_sym_prmtr_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_u_for_sym_prmtr_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                declare var_row_data text; 
                                declare var_old_data text; 
                                begin
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    var_row_data := 
          case when new."external_id" is null then '' else '"' || replace(replace(cast(new."external_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."node_group_id" is null then '' else '"' || replace(replace(cast(new."node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."param_key" is null then '' else '"' || replace(replace(cast(new."param_key" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."param_value" is null then '' else '"' || replace(replace(cast(new."param_value" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end; 
                                    var_old_data := null; 
                                    if 1=1 then 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, row_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                     
                                    values(                                                                                                                                                            
                                      'sym_parameter',                                                                                                                                            
                                      'U',                                                                                                                                                             
                                      5,                                                                                                                                             
                                      
          case when old."external_id" is null then '' else '"' || replace(replace(cast(old."external_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."node_group_id" is null then '' else '"' || replace(replace(cast(old."node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."param_key" is null then '' else '"' || replace(replace(cast(old."param_key" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      var_row_data,                                                                                                                                                      
                                      var_old_data,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_u_for_sym_rtr_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_u_for_sym_rtr_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                declare var_row_data text; 
                                declare var_old_data text; 
                                begin
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    var_row_data := 
          case when new."router_id" is null then '' else '"' || replace(replace(cast(new."router_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_catalog_name" is null then '' else '"' || replace(replace(cast(new."target_catalog_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_schema_name" is null then '' else '"' || replace(replace(cast(new."target_schema_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_table_name" is null then '' else '"' || replace(replace(cast(new."target_table_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."source_node_group_id" is null then '' else '"' || replace(replace(cast(new."source_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_node_group_id" is null then '' else '"' || replace(replace(cast(new."target_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."router_type" is null then '' else '"' || replace(replace(cast(new."router_type" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."router_expression" is null then '' else '"' || replace(replace(cast(new."router_expression" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."sync_on_update" is null then '' else '"' || cast(cast(new."sync_on_update" as numeric) as varchar) || '"' end||','||
          case when new."sync_on_insert" is null then '' else '"' || cast(cast(new."sync_on_insert" as numeric) as varchar) || '"' end||','||
          case when new."sync_on_delete" is null then '' else '"' || cast(cast(new."sync_on_delete" as numeric) as varchar) || '"' end||','||
          case when new."use_source_catalog_schema" is null then '' else '"' || cast(cast(new."use_source_catalog_schema" as numeric) as varchar) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."description" is null then '' else '"' || replace(replace(cast(new."description" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end; 
                                    var_old_data := null; 
                                    if 1=1 then 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, row_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                     
                                    values(                                                                                                                                                            
                                      'sym_router',                                                                                                                                            
                                      'U',                                                                                                                                                             
                                      2,                                                                                                                                             
                                      
          case when old."router_id" is null then '' else '"' || replace(replace(cast(old."router_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      var_row_data,                                                                                                                                                      
                                      var_old_data,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_u_for_sym_tbl_rld_rqst_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_u_for_sym_tbl_rld_rqst_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                declare var_row_data text; 
                                declare var_old_data text; 
                                begin
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    var_row_data := 
          case when new."target_node_id" is null then '' else '"' || replace(replace(cast(new."target_node_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."source_node_id" is null then '' else '"' || replace(replace(cast(new."source_node_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."trigger_id" is null then '' else '"' || replace(replace(cast(new."trigger_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."router_id" is null then '' else '"' || replace(replace(cast(new."router_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."create_table" is null then '' else '"' || cast(cast(new."create_table" as numeric) as varchar) || '"' end||','||
          case when new."delete_first" is null then '' else '"' || cast(cast(new."delete_first" as numeric) as varchar) || '"' end||','||
          case when new."reload_select" is null then '' else '"' || replace(replace(cast(new."reload_select" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."before_custom_sql" is null then '' else '"' || replace(replace(cast(new."before_custom_sql" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."reload_time" is null then '' else '"' || to_char(new."reload_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."load_id" is null then '' else '"' || cast(cast(new."load_id" as numeric) as varchar) || '"' end||','||
          case when new."processed" is null then '' else '"' || cast(cast(new."processed" as numeric) as varchar) || '"' end||','||
          case when new."channel_id" is null then '' else '"' || replace(replace(cast(new."channel_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end; 
                                    var_old_data := null; 
                                    if 1=1 then 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, row_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                     
                                    values(                                                                                                                                                            
                                      'sym_table_reload_request',                                                                                                                                            
                                      'U',                                                                                                                                                             
                                      7,                                                                                                                                             
                                      
          case when old."target_node_id" is null then '' else '"' || replace(replace(cast(old."target_node_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."source_node_id" is null then '' else '"' || replace(replace(cast(old."source_node_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."trigger_id" is null then '' else '"' || replace(replace(cast(old."trigger_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."router_id" is null then '' else '"' || replace(replace(cast(old."router_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."create_time" is null then '' else '"' || to_char(old."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end,                                                                                                                                                      
                                      var_row_data,                                                                                                                                                      
                                      var_old_data,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_u_for_sym_trggr_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_u_for_sym_trggr_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                declare var_row_data text; 
                                declare var_old_data text; 
                                begin
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    var_row_data := 
          case when new."trigger_id" is null then '' else '"' || replace(replace(cast(new."trigger_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."source_catalog_name" is null then '' else '"' || replace(replace(cast(new."source_catalog_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."source_schema_name" is null then '' else '"' || replace(replace(cast(new."source_schema_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."source_table_name" is null then '' else '"' || replace(replace(cast(new."source_table_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."channel_id" is null then '' else '"' || replace(replace(cast(new."channel_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."reload_channel_id" is null then '' else '"' || replace(replace(cast(new."reload_channel_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."sync_on_update" is null then '' else '"' || cast(cast(new."sync_on_update" as numeric) as varchar) || '"' end||','||
          case when new."sync_on_insert" is null then '' else '"' || cast(cast(new."sync_on_insert" as numeric) as varchar) || '"' end||','||
          case when new."sync_on_delete" is null then '' else '"' || cast(cast(new."sync_on_delete" as numeric) as varchar) || '"' end||','||
          case when new."sync_on_incoming_batch" is null then '' else '"' || cast(cast(new."sync_on_incoming_batch" as numeric) as varchar) || '"' end||','||
          case when new."name_for_update_trigger" is null then '' else '"' || replace(replace(cast(new."name_for_update_trigger" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."name_for_insert_trigger" is null then '' else '"' || replace(replace(cast(new."name_for_insert_trigger" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."name_for_delete_trigger" is null then '' else '"' || replace(replace(cast(new."name_for_delete_trigger" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."sync_on_update_condition" is null then '' else '"' || replace(replace(cast(new."sync_on_update_condition" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."sync_on_insert_condition" is null then '' else '"' || replace(replace(cast(new."sync_on_insert_condition" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."sync_on_delete_condition" is null then '' else '"' || replace(replace(cast(new."sync_on_delete_condition" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."custom_before_update_text" is null then '' else '"' || replace(replace(cast(new."custom_before_update_text" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."custom_before_insert_text" is null then '' else '"' || replace(replace(cast(new."custom_before_insert_text" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."custom_before_delete_text" is null then '' else '"' || replace(replace(cast(new."custom_before_delete_text" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."custom_on_update_text" is null then '' else '"' || replace(replace(cast(new."custom_on_update_text" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."custom_on_insert_text" is null then '' else '"' || replace(replace(cast(new."custom_on_insert_text" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."custom_on_delete_text" is null then '' else '"' || replace(replace(cast(new."custom_on_delete_text" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."external_select" is null then '' else '"' || replace(replace(cast(new."external_select" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."tx_id_expression" is null then '' else '"' || replace(replace(cast(new."tx_id_expression" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."channel_expression" is null then '' else '"' || replace(replace(cast(new."channel_expression" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."excluded_column_names" is null then '' else '"' || replace(replace(cast(new."excluded_column_names" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."included_column_names" is null then '' else '"' || replace(replace(cast(new."included_column_names" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."sync_key_names" is null then '' else '"' || replace(replace(cast(new."sync_key_names" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."use_stream_lobs" is null then '' else '"' || cast(cast(new."use_stream_lobs" as numeric) as varchar) || '"' end||','||
          case when new."use_capture_lobs" is null then '' else '"' || cast(cast(new."use_capture_lobs" as numeric) as varchar) || '"' end||','||
          case when new."use_capture_old_data" is null then '' else '"' || cast(cast(new."use_capture_old_data" as numeric) as varchar) || '"' end||','||
          case when new."use_handle_key_updates" is null then '' else '"' || cast(cast(new."use_handle_key_updates" as numeric) as varchar) || '"' end||','||
          case when new."stream_row" is null then '' else '"' || cast(cast(new."stream_row" as numeric) as varchar) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."description" is null then '' else '"' || replace(replace(cast(new."description" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end; 
                                    var_old_data := null; 
                                    if 1=1 then 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, row_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                     
                                    values(                                                                                                                                                            
                                      'sym_trigger',                                                                                                                                            
                                      'U',                                                                                                                                                             
                                      26,                                                                                                                                             
                                      
          case when old."trigger_id" is null then '' else '"' || replace(replace(cast(old."trigger_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      var_row_data,                                                                                                                                                      
                                      var_old_data,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_u_for_sym_trggr_rtr_grplt_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_u_for_sym_trggr_rtr_grplt_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                declare var_row_data text; 
                                declare var_old_data text; 
                                begin
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    var_row_data := 
          case when new."grouplet_id" is null then '' else '"' || replace(replace(cast(new."grouplet_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."trigger_id" is null then '' else '"' || replace(replace(cast(new."trigger_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."router_id" is null then '' else '"' || replace(replace(cast(new."router_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."applies_when" is null then '' else '"' || replace(replace(cast(new."applies_when" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end; 
                                    var_old_data := null; 
                                    if 1=1 then 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, row_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                     
                                    values(                                                                                                                                                            
                                      'sym_trigger_router_grouplet',                                                                                                                                            
                                      'U',                                                                                                                                                             
                                      28,                                                                                                                                             
                                      
          case when old."grouplet_id" is null then '' else '"' || replace(replace(cast(old."grouplet_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."trigger_id" is null then '' else '"' || replace(replace(cast(old."trigger_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."router_id" is null then '' else '"' || replace(replace(cast(old."router_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."applies_when" is null then '' else '"' || replace(replace(cast(old."applies_when" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      var_row_data,                                                                                                                                                      
                                      var_old_data,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_u_for_sym_trggr_rtr_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_u_for_sym_trggr_rtr_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                declare var_row_data text; 
                                declare var_old_data text; 
                                begin
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    var_row_data := 
          case when new."trigger_id" is null then '' else '"' || replace(replace(cast(new."trigger_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."router_id" is null then '' else '"' || replace(replace(cast(new."router_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."enabled" is null then '' else '"' || cast(cast(new."enabled" as numeric) as varchar) || '"' end||','||
          case when new."initial_load_order" is null then '' else '"' || cast(cast(new."initial_load_order" as numeric) as varchar) || '"' end||','||
          case when new."initial_load_select" is null then '' else '"' || replace(replace(cast(new."initial_load_select" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."initial_load_delete_stmt" is null then '' else '"' || replace(replace(cast(new."initial_load_delete_stmt" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."ping_back_enabled" is null then '' else '"' || cast(cast(new."ping_back_enabled" as numeric) as varchar) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."description" is null then '' else '"' || replace(replace(cast(new."description" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end; 
                                    var_old_data := null; 
                                    if 1=1 then 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, row_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                     
                                    values(                                                                                                                                                            
                                      'sym_trigger_router',                                                                                                                                            
                                      'U',                                                                                                                                                             
                                      15,                                                                                                                                             
                                      
          case when old."trigger_id" is null then '' else '"' || replace(replace(cast(old."trigger_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."router_id" is null then '' else '"' || replace(replace(cast(old."router_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      var_row_data,                                                                                                                                                      
                                      var_old_data,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_u_for_sym_trnsfrm_clmn_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_u_for_sym_trnsfrm_clmn_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                declare var_row_data text; 
                                declare var_old_data text; 
                                begin
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    var_row_data := 
          case when new."transform_id" is null then '' else '"' || replace(replace(cast(new."transform_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."include_on" is null then '' else '"' || replace(replace(cast(new."include_on" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_column_name" is null then '' else '"' || replace(replace(cast(new."target_column_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."source_column_name" is null then '' else '"' || replace(replace(cast(new."source_column_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."pk" is null then '' else '"' || cast(cast(new."pk" as numeric) as varchar) || '"' end||','||
          case when new."transform_type" is null then '' else '"' || replace(replace(cast(new."transform_type" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."transform_expression" is null then '' else '"' || replace(replace(cast(new."transform_expression" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."transform_order" is null then '' else '"' || cast(cast(new."transform_order" as numeric) as varchar) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."description" is null then '' else '"' || replace(replace(cast(new."description" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end; 
                                    var_old_data := null; 
                                    if 1=1 then 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, row_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                     
                                    values(                                                                                                                                                            
                                      'sym_transform_column',                                                                                                                                            
                                      'U',                                                                                                                                                             
                                      13,                                                                                                                                             
                                      
          case when old."transform_id" is null then '' else '"' || replace(replace(cast(old."transform_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."include_on" is null then '' else '"' || replace(replace(cast(old."include_on" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."target_column_name" is null then '' else '"' || replace(replace(cast(old."target_column_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      var_row_data,                                                                                                                                                      
                                      var_old_data,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_u_for_sym_trnsfrm_tbl_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_u_for_sym_trnsfrm_tbl_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                declare var_row_data text; 
                                declare var_old_data text; 
                                begin
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    var_row_data := 
          case when new."transform_id" is null then '' else '"' || replace(replace(cast(new."transform_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."source_node_group_id" is null then '' else '"' || replace(replace(cast(new."source_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_node_group_id" is null then '' else '"' || replace(replace(cast(new."target_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."transform_point" is null then '' else '"' || replace(replace(cast(new."transform_point" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."source_catalog_name" is null then '' else '"' || replace(replace(cast(new."source_catalog_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."source_schema_name" is null then '' else '"' || replace(replace(cast(new."source_schema_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."source_table_name" is null then '' else '"' || replace(replace(cast(new."source_table_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_catalog_name" is null then '' else '"' || replace(replace(cast(new."target_catalog_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_schema_name" is null then '' else '"' || replace(replace(cast(new."target_schema_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."target_table_name" is null then '' else '"' || replace(replace(cast(new."target_table_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."update_first" is null then '' else '"' || cast(cast(new."update_first" as numeric) as varchar) || '"' end||','||
          case when new."update_action" is null then '' else '"' || replace(replace(cast(new."update_action" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."delete_action" is null then '' else '"' || replace(replace(cast(new."delete_action" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."transform_order" is null then '' else '"' || cast(cast(new."transform_order" as numeric) as varchar) || '"' end||','||
          case when new."column_policy" is null then '' else '"' || replace(replace(cast(new."column_policy" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."description" is null then '' else '"' || replace(replace(cast(new."description" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end; 
                                    var_old_data := null; 
                                    if 1=1 then 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, row_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                     
                                    values(                                                                                                                                                            
                                      'sym_transform_table',                                                                                                                                            
                                      'U',                                                                                                                                                             
                                      4,                                                                                                                                             
                                      
          case when old."transform_id" is null then '' else '"' || replace(replace(cast(old."transform_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."source_node_group_id" is null then '' else '"' || replace(replace(cast(old."source_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when old."target_node_group_id" is null then '' else '"' || replace(replace(cast(old."target_node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      var_row_data,                                                                                                                                                      
                                      var_old_data,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.fsym_on_u_for_sym_xtnsn_ntrt();

CREATE OR REPLACE FUNCTION public.fsym_on_u_for_sym_xtnsn_ntrt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$                                                                                                                
                                declare var_row_data text; 
                                declare var_old_data text; 
                                begin
                                   
                                  if 1=1 and 1=1 then                                                                                                 
                                    var_row_data := 
          case when new."extension_id" is null then '' else '"' || replace(replace(cast(new."extension_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."extension_type" is null then '' else '"' || replace(replace(cast(new."extension_type" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."interface_name" is null then '' else '"' || replace(replace(cast(new."interface_name" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."node_group_id" is null then '' else '"' || replace(replace(cast(new."node_group_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."enabled" is null then '' else '"' || cast(cast(new."enabled" as numeric) as varchar) || '"' end||','||
          case when new."extension_order" is null then '' else '"' || cast(cast(new."extension_order" as numeric) as varchar) || '"' end||','||
          case when new."extension_text" is null then '' else '"' || replace(replace(cast(new."extension_text" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."create_time" is null then '' else '"' || to_char(new."create_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end||','||
          case when new."last_update_by" is null then '' else '"' || replace(replace(cast(new."last_update_by" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end||','||
          case when new."last_update_time" is null then '' else '"' || to_char(new."last_update_time", 'YYYY-MM-DD HH24:MI:SS.US') || '"' end; 
                                    var_old_data := null; 
                                    if 1=1 then 
                                    insert into "public".sym_data                                                                                                                     
                                    (table_name, event_type, trigger_hist_id, pk_data, row_data, old_data, channel_id, transaction_id, source_node_id, external_data, create_time)                     
                                    values(                                                                                                                                                            
                                      'sym_extension',                                                                                                                                            
                                      'U',                                                                                                                                                             
                                      24,                                                                                                                                             
                                      
          case when old."extension_id" is null then '' else '"' || replace(replace(cast(old."extension_id" as varchar),$$\$$,$$\\$$),'"',$$\"$$) || '"' end,                                                                                                                                                      
                                      var_row_data,                                                                                                                                                      
                                      var_old_data,                                                                                                                                                   
                                      'config',                                                                                                                                                
                                      txid_current(),                                                                                                                                               
                                      "public".sym_node_disabled(),                                                                                                                   
                                      null,                                                                                                                                               
                                      CURRENT_TIMESTAMP                                                                                                                
                                    );                                                                                                                                                                 
                                  end if;                                                                                                                                                              
                                  end if;                                                                                                                                                              
                                                                                                                                                                               
                                  return null;                                                                                                                                                         
                                end;                                                                                                                                                                   
                                $function$
;

-- DROP FUNCTION public.func_remove_oids_from_tables_temp();

CREATE OR REPLACE FUNCTION public.func_remove_oids_from_tables_temp()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    rec RECORD;
    cmd text;
BEGIN
    cmd := '';
    
FOR rec IN SELECT
'ALTER TABLE ' ||quote_ident(c.relname) || ' SET WITHOUT OIDS;' AS name 
FROM pg_catalog.pg_class c
    LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind ='r'
     AND n.nspname <> 'pg_catalog'
     AND n.nspname <> 'information_schema'
     AND n.nspname !~ '^pg_toast'
 AND pg_catalog.pg_table_is_visible(c.oid) AND c.relhasoids='t'
 LOOP
        cmd := cmd || rec.name;
    END LOOP;

EXECUTE cmd;
    RETURN;
END;
$function$
;

-- DROP FUNCTION public.func_search_all_tables(text, text);

CREATE OR REPLACE FUNCTION public.func_search_all_tables(searchtext text, searchfield text DEFAULT NULL::text)
 RETURNS TABLE(table_name text, id bigint, matchfieldname text, matchfielddata text)
 LANGUAGE plpgsql
AS $function$
DECLARE
  tableDetails CURSOR FOR SELECT * FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
  searchStringSql text := '';
  tableFields information_schema.columns;
  output text;
  matchFields text :='';
  idField text;
BEGIN
    -- Get all table names from information schema
    FOR tableDetail in tableDetails LOOP
        idField:=NULL;
        --Begin of Generate case statements for matched columns
        matchFields:= ' CASE ';

        --Loop on all fields in the current table
        FOR tableFields IN SELECT * FROM information_schema.columns WHERE columns.table_schema = 'public' AND columns.table_name = tableDetail.table_name AND ( columns.column_name = searchField OR ( searchField is null AND ( data_type = 'text' OR data_type = 'character varying' ) ) ) LOOP
            -- Get all fields of data_type = text and make ilike '%searchText%' statements
            searchStringSql := searchStringSql || tableFields.column_name || E' ILIKE \'%' || searchText || E'%\' OR ';
            -- Get the column name in which we found match
            matchFields := matchFields || ' WHEN ' || tableFields.column_name || E' ILIKE \'%' || searchText || E'%\' THEN \'' || tableFields.column_name || E' ~~~~Record: \'||' || tableFields.column_name;
        END LOOP;

        matchFields := matchFields || ' END' ;
        --End of Generate case statements for matched columns

        --chking if table contains the id field, if not, we display the row id as -1
        SELECT 
            columns.column_name into idField
        FROM
            information_schema.columns
        WHERE
            columns.table_name = tableDetail.table_name
            AND columns.column_name = 'id'
            AND columns.table_schema = 'public'; 

        --If ID field is not present, we dispaly the id as -1 (for tables like states that dont have the id field)
        IF idField is NULL THEN 
          idField:= E'-1'; 
        END IF;     

        --Execute the prepared SQL
        IF searchStringSql != '' THEN
           searchStringSql := substring( searchStringSql from 1 for length(searchStringSql)-3 );
            RETURN QUERY EXECUTE E'
            SELECT
                   table_name,
                   ' || idField || E'::bigint as id,
                   data[1] AS field_name,
                   data[2] AS field_data
            FROM (
                   SELECT \'' || tableDetail.table_name ||E'\'::text as table_name,
                          ' || idField || E' as id,
                          regexp_split_to_array ( '|| matchFields ||E', \'~~~~Record: \' ) as data
                   FROM
                   ' || tableDetail.table_name || '
                   WHERE
                   ' || searchStringSql || '
                  ) data_from_matched_records ';
        END IF;

        searchStringSql :='' ;
    END LOOP;

END;
$function$
;

-- DROP FUNCTION public.func_testing_everywhere_function(int4);

CREATE OR REPLACE FUNCTION public.func_testing_everywhere_function(integer)
 RETURNS SETOF typ_error_msg
 LANGUAGE plpgsql
AS $function$
DECLARE

	pCid								ALIAS FOR $1;


BEGIN

	IF ( pCid <= 0 ) THEN
		RAISE EXCEPTION 'Testing';
	END IF;

	RETURN;
END;
$function$
;

-- DROP FUNCTION public.g_int_compress(internal);

CREATE OR REPLACE FUNCTION public.g_int_compress(internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$g_int_compress$function$
;

-- DROP FUNCTION public.g_int_consistent(internal, _int4, int2, oid, internal);

CREATE OR REPLACE FUNCTION public.g_int_consistent(internal, integer[], smallint, oid, internal)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$g_int_consistent$function$
;

-- DROP FUNCTION public.g_int_decompress(internal);

CREATE OR REPLACE FUNCTION public.g_int_decompress(internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$g_int_decompress$function$
;

-- DROP FUNCTION public.g_int_options(internal);

CREATE OR REPLACE FUNCTION public.g_int_options(internal)
 RETURNS void
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE
AS '$libdir/_int', $function$g_int_options$function$
;

-- DROP FUNCTION public.g_int_penalty(internal, internal, internal);

CREATE OR REPLACE FUNCTION public.g_int_penalty(internal, internal, internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$g_int_penalty$function$
;

-- DROP FUNCTION public.g_int_picksplit(internal, internal);

CREATE OR REPLACE FUNCTION public.g_int_picksplit(internal, internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$g_int_picksplit$function$
;

-- DROP FUNCTION public.g_int_same(_int4, _int4, internal);

CREATE OR REPLACE FUNCTION public.g_int_same(integer[], integer[], internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$g_int_same$function$
;

-- DROP FUNCTION public.g_int_union(internal, internal);

CREATE OR REPLACE FUNCTION public.g_int_union(internal, internal)
 RETURNS integer[]
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$g_int_union$function$
;

-- DROP FUNCTION public.g_intbig_compress(internal);

CREATE OR REPLACE FUNCTION public.g_intbig_compress(internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$g_intbig_compress$function$
;

-- DROP FUNCTION public.g_intbig_consistent(internal, _int4, int2, oid, internal);

CREATE OR REPLACE FUNCTION public.g_intbig_consistent(internal, integer[], smallint, oid, internal)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$g_intbig_consistent$function$
;

-- DROP FUNCTION public.g_intbig_decompress(internal);

CREATE OR REPLACE FUNCTION public.g_intbig_decompress(internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$g_intbig_decompress$function$
;

-- DROP FUNCTION public.g_intbig_options(internal);

CREATE OR REPLACE FUNCTION public.g_intbig_options(internal)
 RETURNS void
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE
AS '$libdir/_int', $function$g_intbig_options$function$
;

-- DROP FUNCTION public.g_intbig_penalty(internal, internal, internal);

CREATE OR REPLACE FUNCTION public.g_intbig_penalty(internal, internal, internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$g_intbig_penalty$function$
;

-- DROP FUNCTION public.g_intbig_picksplit(internal, internal);

CREATE OR REPLACE FUNCTION public.g_intbig_picksplit(internal, internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$g_intbig_picksplit$function$
;

-- DROP FUNCTION public.g_intbig_same(intbig_gkey, intbig_gkey, internal);

CREATE OR REPLACE FUNCTION public.g_intbig_same(intbig_gkey, intbig_gkey, internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$g_intbig_same$function$
;

-- DROP FUNCTION public.g_intbig_union(internal, internal);

CREATE OR REPLACE FUNCTION public.g_intbig_union(internal, internal)
 RETURNS intbig_gkey
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$g_intbig_union$function$
;

-- DROP FUNCTION public.ghstore_compress(internal);

CREATE OR REPLACE FUNCTION public.ghstore_compress(internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$ghstore_compress$function$
;

-- DROP FUNCTION public.ghstore_consistent(internal, hstore, int2, oid, internal);

CREATE OR REPLACE FUNCTION public.ghstore_consistent(internal, hstore, smallint, oid, internal)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$ghstore_consistent$function$
;

-- DROP FUNCTION public.ghstore_decompress(internal);

CREATE OR REPLACE FUNCTION public.ghstore_decompress(internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$ghstore_decompress$function$
;

-- DROP FUNCTION public.ghstore_in(cstring);

CREATE OR REPLACE FUNCTION public.ghstore_in(cstring)
 RETURNS ghstore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$ghstore_in$function$
;

-- DROP FUNCTION public.ghstore_options(internal);

CREATE OR REPLACE FUNCTION public.ghstore_options(internal)
 RETURNS void
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE
AS '$libdir/hstore', $function$ghstore_options$function$
;

-- DROP FUNCTION public.ghstore_out(ghstore);

CREATE OR REPLACE FUNCTION public.ghstore_out(ghstore)
 RETURNS cstring
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$ghstore_out$function$
;

-- DROP FUNCTION public.ghstore_penalty(internal, internal, internal);

CREATE OR REPLACE FUNCTION public.ghstore_penalty(internal, internal, internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$ghstore_penalty$function$
;

-- DROP FUNCTION public.ghstore_picksplit(internal, internal);

CREATE OR REPLACE FUNCTION public.ghstore_picksplit(internal, internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$ghstore_picksplit$function$
;

-- DROP FUNCTION public.ghstore_same(ghstore, ghstore, internal);

CREATE OR REPLACE FUNCTION public.ghstore_same(ghstore, ghstore, internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$ghstore_same$function$
;

-- DROP FUNCTION public.ghstore_union(internal, internal);

CREATE OR REPLACE FUNCTION public.ghstore_union(internal, internal)
 RETURNS ghstore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$ghstore_union$function$
;

-- DROP FUNCTION public.gin_consistent_hstore(internal, int2, hstore, int4, internal, internal);

CREATE OR REPLACE FUNCTION public.gin_consistent_hstore(internal, smallint, hstore, integer, internal, internal)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$gin_consistent_hstore$function$
;

-- DROP FUNCTION public.gin_extract_hstore(hstore, internal);

CREATE OR REPLACE FUNCTION public.gin_extract_hstore(hstore, internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$gin_extract_hstore$function$
;

-- DROP FUNCTION public.gin_extract_hstore_query(hstore, internal, int2, internal, internal);

CREATE OR REPLACE FUNCTION public.gin_extract_hstore_query(hstore, internal, smallint, internal, internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$gin_extract_hstore_query$function$
;

-- DROP FUNCTION public.gin_extract_query_trgm(text, internal, int2, internal, internal, internal, internal);

CREATE OR REPLACE FUNCTION public.gin_extract_query_trgm(text, internal, smallint, internal, internal, internal, internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$gin_extract_query_trgm$function$
;

-- DROP FUNCTION public.gin_extract_value_trgm(text, internal);

CREATE OR REPLACE FUNCTION public.gin_extract_value_trgm(text, internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$gin_extract_value_trgm$function$
;

-- DROP FUNCTION public.gin_trgm_consistent(internal, int2, text, int4, internal, internal, internal, internal);

CREATE OR REPLACE FUNCTION public.gin_trgm_consistent(internal, smallint, text, integer, internal, internal, internal, internal)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$gin_trgm_consistent$function$
;

-- DROP FUNCTION public.gin_trgm_triconsistent(internal, int2, text, int4, internal, internal, internal);

CREATE OR REPLACE FUNCTION public.gin_trgm_triconsistent(internal, smallint, text, integer, internal, internal, internal)
 RETURNS "char"
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$gin_trgm_triconsistent$function$
;

-- DROP FUNCTION public.ginint4_consistent(internal, int2, _int4, int4, internal, internal, internal, internal);

CREATE OR REPLACE FUNCTION public.ginint4_consistent(internal, smallint, integer[], integer, internal, internal, internal, internal)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$ginint4_consistent$function$
;

-- DROP FUNCTION public.ginint4_queryextract(_int4, internal, int2, internal, internal, internal, internal);

CREATE OR REPLACE FUNCTION public.ginint4_queryextract(integer[], internal, smallint, internal, internal, internal, internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$ginint4_queryextract$function$
;

-- DROP FUNCTION public.gtrgm_compress(internal);

CREATE OR REPLACE FUNCTION public.gtrgm_compress(internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$gtrgm_compress$function$
;

-- DROP FUNCTION public.gtrgm_consistent(internal, text, int2, oid, internal);

CREATE OR REPLACE FUNCTION public.gtrgm_consistent(internal, text, smallint, oid, internal)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$gtrgm_consistent$function$
;

-- DROP FUNCTION public.gtrgm_decompress(internal);

CREATE OR REPLACE FUNCTION public.gtrgm_decompress(internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$gtrgm_decompress$function$
;

-- DROP FUNCTION public.gtrgm_distance(internal, text, int2, oid, internal);

CREATE OR REPLACE FUNCTION public.gtrgm_distance(internal, text, smallint, oid, internal)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$gtrgm_distance$function$
;

-- DROP FUNCTION public.gtrgm_in(cstring);

CREATE OR REPLACE FUNCTION public.gtrgm_in(cstring)
 RETURNS gtrgm
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$gtrgm_in$function$
;

-- DROP FUNCTION public.gtrgm_options(internal);

CREATE OR REPLACE FUNCTION public.gtrgm_options(internal)
 RETURNS void
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE
AS '$libdir/pg_trgm', $function$gtrgm_options$function$
;

-- DROP FUNCTION public.gtrgm_out(gtrgm);

CREATE OR REPLACE FUNCTION public.gtrgm_out(gtrgm)
 RETURNS cstring
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$gtrgm_out$function$
;

-- DROP FUNCTION public.gtrgm_penalty(internal, internal, internal);

CREATE OR REPLACE FUNCTION public.gtrgm_penalty(internal, internal, internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$gtrgm_penalty$function$
;

-- DROP FUNCTION public.gtrgm_picksplit(internal, internal);

CREATE OR REPLACE FUNCTION public.gtrgm_picksplit(internal, internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$gtrgm_picksplit$function$
;

-- DROP FUNCTION public.gtrgm_same(gtrgm, gtrgm, internal);

CREATE OR REPLACE FUNCTION public.gtrgm_same(gtrgm, gtrgm, internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$gtrgm_same$function$
;

-- DROP FUNCTION public.gtrgm_union(internal, internal);

CREATE OR REPLACE FUNCTION public.gtrgm_union(internal, internal)
 RETURNS gtrgm
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$gtrgm_union$function$
;

-- DROP FUNCTION public.hs_concat(hstore, hstore);

CREATE OR REPLACE FUNCTION public.hs_concat(hstore, hstore)
 RETURNS hstore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_concat$function$
;

-- DROP FUNCTION public.hs_contained(hstore, hstore);

CREATE OR REPLACE FUNCTION public.hs_contained(hstore, hstore)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_contained$function$
;

-- DROP FUNCTION public.hs_contains(hstore, hstore);

CREATE OR REPLACE FUNCTION public.hs_contains(hstore, hstore)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_contains$function$
;

-- DROP FUNCTION public.hstore(_text);

CREATE OR REPLACE FUNCTION public.hstore(text[])
 RETURNS hstore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_from_array$function$
;

-- DROP FUNCTION public.hstore(_text, _text);

CREATE OR REPLACE FUNCTION public.hstore(text[], text[])
 RETURNS hstore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE
AS '$libdir/hstore', $function$hstore_from_arrays$function$
;

-- DROP FUNCTION public.hstore(record);

CREATE OR REPLACE FUNCTION public.hstore(record)
 RETURNS hstore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE
AS '$libdir/hstore', $function$hstore_from_record$function$
;

-- DROP FUNCTION public.hstore(text, text);

CREATE OR REPLACE FUNCTION public.hstore(text, text)
 RETURNS hstore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE
AS '$libdir/hstore', $function$hstore_from_text$function$
;

-- DROP FUNCTION public.hstore_cmp(hstore, hstore);

CREATE OR REPLACE FUNCTION public.hstore_cmp(hstore, hstore)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_cmp$function$
;

-- DROP FUNCTION public.hstore_eq(hstore, hstore);

CREATE OR REPLACE FUNCTION public.hstore_eq(hstore, hstore)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_eq$function$
;

-- DROP FUNCTION public.hstore_ge(hstore, hstore);

CREATE OR REPLACE FUNCTION public.hstore_ge(hstore, hstore)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_ge$function$
;

-- DROP FUNCTION public.hstore_gt(hstore, hstore);

CREATE OR REPLACE FUNCTION public.hstore_gt(hstore, hstore)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_gt$function$
;

-- DROP FUNCTION public.hstore_hash(hstore);

CREATE OR REPLACE FUNCTION public.hstore_hash(hstore)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_hash$function$
;

-- DROP FUNCTION public.hstore_hash_extended(hstore, int8);

CREATE OR REPLACE FUNCTION public.hstore_hash_extended(hstore, bigint)
 RETURNS bigint
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_hash_extended$function$
;

-- DROP FUNCTION public.hstore_in(cstring);

CREATE OR REPLACE FUNCTION public.hstore_in(cstring)
 RETURNS hstore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_in$function$
;

-- DROP FUNCTION public.hstore_le(hstore, hstore);

CREATE OR REPLACE FUNCTION public.hstore_le(hstore, hstore)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_le$function$
;

-- DROP FUNCTION public.hstore_lt(hstore, hstore);

CREATE OR REPLACE FUNCTION public.hstore_lt(hstore, hstore)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_lt$function$
;

-- DROP FUNCTION public.hstore_ne(hstore, hstore);

CREATE OR REPLACE FUNCTION public.hstore_ne(hstore, hstore)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_ne$function$
;

-- DROP FUNCTION public.hstore_out(hstore);

CREATE OR REPLACE FUNCTION public.hstore_out(hstore)
 RETURNS cstring
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_out$function$
;

-- DROP FUNCTION public.hstore_recv(internal);

CREATE OR REPLACE FUNCTION public.hstore_recv(internal)
 RETURNS hstore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_recv$function$
;

-- DROP FUNCTION public.hstore_send(hstore);

CREATE OR REPLACE FUNCTION public.hstore_send(hstore)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_send$function$
;

-- DROP FUNCTION public.hstore_to_array(hstore);

CREATE OR REPLACE FUNCTION public.hstore_to_array(hstore)
 RETURNS text[]
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_to_array$function$
;

-- DROP FUNCTION public.hstore_to_json(hstore);

CREATE OR REPLACE FUNCTION public.hstore_to_json(hstore)
 RETURNS json
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_to_json$function$
;

-- DROP FUNCTION public.hstore_to_json_loose(hstore);

CREATE OR REPLACE FUNCTION public.hstore_to_json_loose(hstore)
 RETURNS json
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_to_json_loose$function$
;

-- DROP FUNCTION public.hstore_to_jsonb(hstore);

CREATE OR REPLACE FUNCTION public.hstore_to_jsonb(hstore)
 RETURNS jsonb
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_to_jsonb$function$
;

-- DROP FUNCTION public.hstore_to_jsonb_loose(hstore);

CREATE OR REPLACE FUNCTION public.hstore_to_jsonb_loose(hstore)
 RETURNS jsonb
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_to_jsonb_loose$function$
;

-- DROP FUNCTION public.hstore_to_matrix(hstore);

CREATE OR REPLACE FUNCTION public.hstore_to_matrix(hstore)
 RETURNS text[]
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_to_matrix$function$
;

-- DROP FUNCTION public.hstore_version_diag(hstore);

CREATE OR REPLACE FUNCTION public.hstore_version_diag(hstore)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_version_diag$function$
;

-- DROP FUNCTION public.icount(_int4);

CREATE OR REPLACE FUNCTION public.icount(integer[])
 RETURNS integer
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$icount$function$
;

-- DROP FUNCTION public.idx(_int4, int4);

CREATE OR REPLACE FUNCTION public.idx(integer[], integer)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$idx$function$
;

-- DROP FUNCTION public.immutable_concat_ws(in text, variadic _text);

CREATE OR REPLACE FUNCTION public.immutable_concat_ws(text, VARIADIC text[])
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT concat_ws($1, $2); $function$
;

-- DROP PROCEDURE public.insert_into_cached_gl_post_month_totals_table(int4, int4);

CREATE OR REPLACE PROCEDURE public.insert_into_cached_gl_post_month_totals_table(IN lclientid integer, IN lpropertyid integer)
 LANGUAGE plpgsql
AS $procedure$

DECLARE

BEGIN

    INSERT INTO cached_gl_post_month_totals (cid,gl_transaction_type_id,property_id,gl_account_id,post_month,gl_dimension_id,gl_book_id,department_id,is_confidential,accrual_total,cash_total,updated_on,created_on)

    SELECT
	    gh.cid,
	    gh.gl_transaction_type_id,
	    gd.property_id,
	    CASE
		    WHEN gd.accrual_gl_account_id IS NOT NULL THEN
			    gd.accrual_gl_account_id
		    ELSE
			    gd.cash_gl_account_id
		    END AS gl_account_id,
	    gd.post_month,
	    gd.gl_dimension_id,
	    gh.gl_book_id,
	    gd.company_department_id AS department_id,
	    gd.is_confidential,
	    sum(
		    CASE WHEN gd.accrual_gl_account_id IS NOT NULL THEN
			         gd.amount
		         ELSE
			         0
			    END ) AS accrual_total,
	    sum(
		    CASE WHEN gd.cash_gl_account_id IS NOT NULL THEN
			         gd.amount
		         ELSE
			         0
			    END ) AS cash_total,
	    NOW() AS updated_on,
	    NOW() AS created_on
    FROM
	    gl_headers gh
		    JOIN gl_details gd ON ( gh.cid = gd.cid AND gh.id = gd.gl_header_id )
		    JOIN periods p ON ( gd.cid = p.cid AND gd.property_id = p.property_id AND gd.post_month = p.post_month AND p.gl_locked_on::date <= TO_CHAR( NOW()::date,'yyyy-mm-dd' )::date )
    WHERE
	    gh.gl_header_status_type_id in ( 1, 3 )
		    AND gh.is_template is false
    GROUP BY
	    1, 2, 3, 4, 5, 6, 7, 8, 9;

	COMMIT;
END;
$procedure$
;

-- DROP FUNCTION public.insurance_policies_update_ins_carrier_names_correction_map();

CREATE OR REPLACE FUNCTION public.insurance_policies_update_ins_carrier_names_correction_map()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN

new.insurance_carrier_name_bad := lower(new.insurance_carrier_name_bad);
RETURN new;

END
$function$
;

-- DROP FUNCTION public.insurance_policies_update_payment_failure(int4, int4, int4, date, int4);

CREATE OR REPLACE FUNCTION public.insurance_policies_update_payment_failure(integer, integer, integer, date, integer)
 RETURNS SETOF typ_error_msg
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
pId ALIAS FOR $1;
pInsurancePolicyStatusTypeId ALIAS FOR $2;
pIsPaymentFailed ALIAS FOR $3;
pLapsedOn ALIAS FOR $4;
pCurrentUserId ALIAS FOR $5;
lAffectedRows INTEGER;
lErrorMsg typ_error_msg%ROWTYPE;
BEGIN
UPDATE public.insurance_policies SET
insurance_policy_status_type_id = pInsurancePolicyStatusTypeId,
is_payment_failed = pIsPaymentFailed,
lapsed_on = pLapsedOn,
updated_by = pCurrentUserId,
updated_on = NOW()
WHERE
id = pId;
GET DIAGNOSTICS lAffectedRows = ROW_COUNT;
IF( lAffectedRows != 1 )THEN
lErrorMsg.type := -2;
lErrorMsg.message := 'Failed to update insurance policy. The record may have been deleted or is locked.';
RETURN NEXT lErrorMsg;
END IF;
RETURN;
END;
$function$
;

-- DROP FUNCTION public.insurance_policies_update_post_dates(int4, int4, timestamptz, date, int4);

CREATE OR REPLACE FUNCTION public.insurance_policies_update_post_dates(integer, integer, timestamp with time zone, date, integer)
 RETURNS SETOF typ_error_msg
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
pId ALIAS FOR $1;
pInsurancePolicyStatusTypeId ALIAS FOR $2;
pLastPostedOn ALIAS FOR $3;
pNextPostOn ALIAS FOR $4;
pCurrentUserId ALIAS FOR $5;
lAffectedRows INTEGER;
lErrorMsg typ_error_msg%ROWTYPE;
BEGIN
UPDATE public.insurance_policies SET
insurance_policy_status_type_id = pInsurancePolicyStatusTypeId,
last_posted_on = pLastPostedOn,
next_post_on = pNextPostOn,
updated_by = pCurrentUserId,
updated_on = NOW()
WHERE
id = pId;
GET DIAGNOSTICS lAffectedRows = ROW_COUNT;
IF( lAffectedRows != 1 )THEN
lErrorMsg.type := -2;
lErrorMsg.message := 'Failed to update insurance policy. The record may have been deleted or is locked.';
RETURN NEXT lErrorMsg;
END IF;
RETURN;
END;
$function$
;

-- DROP FUNCTION public.intarray_del_elem(_int4, int4);

CREATE OR REPLACE FUNCTION public.intarray_del_elem(integer[], integer)
 RETURNS integer[]
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$intarray_del_elem$function$
;

-- DROP FUNCTION public.intarray_push_array(_int4, _int4);

CREATE OR REPLACE FUNCTION public.intarray_push_array(integer[], integer[])
 RETURNS integer[]
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$intarray_push_array$function$
;

-- DROP FUNCTION public.intarray_push_elem(_int4, int4);

CREATE OR REPLACE FUNCTION public.intarray_push_elem(integer[], integer)
 RETURNS integer[]
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$intarray_push_elem$function$
;

-- DROP FUNCTION public.intset(int4);

CREATE OR REPLACE FUNCTION public.intset(integer)
 RETURNS integer[]
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$intset$function$
;

-- DROP FUNCTION public.intset_subtract(_int4, _int4);

CREATE OR REPLACE FUNCTION public.intset_subtract(integer[], integer[])
 RETURNS integer[]
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$intset_subtract$function$
;

-- DROP FUNCTION public.intset_union_elem(_int4, int4);

CREATE OR REPLACE FUNCTION public.intset_union_elem(integer[], integer)
 RETURNS integer[]
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$intset_union_elem$function$
;

-- DROP FUNCTION public.isdefined(hstore, text);

CREATE OR REPLACE FUNCTION public.isdefined(hstore, text)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_defined$function$
;

-- DROP FUNCTION public.isexists(hstore, text);

CREATE OR REPLACE FUNCTION public.isexists(hstore, text)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_exists$function$
;

-- DROP FUNCTION public.normal_rand(int4, float8, float8);

CREATE OR REPLACE FUNCTION public.normal_rand(integer, double precision, double precision)
 RETURNS SETOF double precision
 LANGUAGE c
 STRICT
AS '$libdir/tablefunc', $function$normal_rand$function$
;

-- DROP FUNCTION public."parallel"(varchar);

CREATE OR REPLACE FUNCTION public.parallel(query_text character varying)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
jobs integer:=2;
queries varchar[];
total_queries integer:=0;
database_name varchar;
required_jobs integer:=0;
current_jobs integer:=0;
pending_jobs integer;
counter integer:=0;
query_status integer[];
busy_temp integer:=-1;
query_result varchar;
port_number varchar;

BEGIN

    select current_database() into database_name;
    select setting INTO port_number from pg_settings where name = 'port';

    --splitting all queries by ';' into query_details
    SELECT
        array_agg( ( regexp_replace ( query, E'', '', 'g' ) ) ) as details
    FROM
        (
          SELECT
              *,
              row_number ( ) over ( ) AS number
          FROM
              regexp_split_to_table ( regexp_replace ( query_text, E';(\n)+(?=[a-zA-Z])', ';', 'g' ), E';' ) query
        ) t
    WHERE
        trim ( regexp_replace ( query, E'[\r\n\s]+', ' ', 'g' ) ) <> ''
    INTO queries;

    required_jobs = array_length(queries, 1);
    pending_jobs = array_length(queries, 1);

    <<outer>>
    LOOP

        --Sending a query
        WHILE current_jobs < jobs AND required_jobs > 0 AND pending_jobs > 0
        LOOP
          current_jobs:=current_jobs + 1;
          pending_jobs:=pending_jobs - 1;
          counter:=counter+1;

          PERFORM dblink_connect ( 'virtual_connection_'|| counter, 'port=' || port_number ||' dbname='||database_name );
          PERFORM dblink_send_query( 'virtual_connection_'|| counter, queries[counter] );
          query_status[counter]:=1;

          --raise notice E'Pushed query: \r\n %\r\n\r\n', queries[counter];
        END LOOP;

        FOR job_number IN 1..counter
        LOOP

        if  query_status[job_number] = 1   THEN
            SELECT dblink_is_busy('virtual_connection_'||job_number) INTO busy_temp ;

            IF busy_temp = 0 THEN
                raise INFO E'\r\n%', queries[job_number];

               SELECT * from dblink_get_result('virtual_connection_'||job_number,false) AS temp(result varchar) into query_result;

                raise INFO E'OUTPUT: % is % \r\n\r\n', 'virtual_connection_'||job_number, query_result;


               PERFORM dblink_disconnect('virtual_connection_'||job_number);
               required_jobs:=required_jobs-1;
               current_jobs:=current_jobs-1;
               query_status[job_number]:=0;
               --raise notice 'Disconnected %, required jobs %, pending jobs %', job_number, required_jobs, current_jobs;

               IF required_jobs = 0 THEN
               raise notice 'All jobs done';
                  EXIT outer;
               END IF;

            END IF;
        END IF;


        END LOOP;
        perform pg_sleep(0.05);
    END LOOP;
    END;
$function$
;

-- DROP FUNCTION public.pg_freespace(in regclass, out int8, out int2);

CREATE OR REPLACE FUNCTION public.pg_freespace(rel regclass, OUT blkno bigint, OUT avail smallint)
 RETURNS SETOF record
 LANGUAGE sql
 PARALLEL SAFE
AS $function$
  SELECT blkno, pg_freespace($1, blkno) AS avail
  FROM generate_series(0, pg_relation_size($1) / current_setting('block_size')::bigint - 1) AS blkno;
$function$
;

-- DROP FUNCTION public.pg_freespace(regclass, int8);

CREATE OR REPLACE FUNCTION public.pg_freespace(regclass, bigint)
 RETURNS smallint
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/pg_freespacemap', $function$pg_freespace$function$
;

-- DROP FUNCTION public.populate_record(anyelement, hstore);

CREATE OR REPLACE FUNCTION public.populate_record(anyelement, hstore)
 RETURNS anyelement
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE
AS '$libdir/hstore', $function$hstore_populate_record$function$
;

-- DROP FUNCTION public.querytree(query_int);

CREATE OR REPLACE FUNCTION public.querytree(query_int)
 RETURNS text
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$querytree$function$
;

-- DROP FUNCTION public.rabbitmq_complete_batch(int4);

CREATE OR REPLACE FUNCTION public.rabbitmq_complete_batch(pbatchid integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE	
	lStatementStartTime		TIMESTAMP;
BEGIN
	
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Completes all messages for the specified batch
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Messages are "completed" by deletion from rabbitmq_staged_messages table
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	lStatementStartTime := clock_timestamp();
	
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Validate, initialize and sanitize arguments
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	IF (COALESCE(pBatchId, 0) <= 0) THEN
		RAISE EXCEPTION 'Parameter pBatchId must be a valid id';
	END IF;

	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Delete batch records
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	DELETE FROM
		public.rabbitmq_staged_messages
	WHERE
		batch_id = pBatchId;
	
	RETURN;
END;

$function$
;

-- DROP FUNCTION public.rabbitmq_fail_message(int4, varchar);

CREATE OR REPLACE FUNCTION public.rabbitmq_fail_message(pid integer, pfailedreason character varying)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE	
	lStatementStartTime		TIMESTAMP;
BEGIN
	
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Fails the specified message
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Inserts specified message into to rabbitmq_failed_messages table. This function should always be
	--  used in conjunction with an outer transaction (outside functions) and rabbitmq_pop_messages(...).
	--  The logic within rabbitmq_pop_messages(...) locks, deletes and returns a batch of messages. If
	--  the consuming publisher script discovers a corrupt/invalid message, this function allows us to
	--  preserve the original message record as well as the date/reason of failure. On commit of outer
	--  transaction, deletion of rows from "staged" table occurs as well as inserts on this "failed" table.
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	lStatementStartTime := clock_timestamp();
	
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Validate, initialize and sanitize arguments
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	IF (COALESCE(pId, 0) <= 0) THEN
		RAISE EXCEPTION 'Parameter pId must be a valid id';
	ELSIF (COALESCE(pFailedReason, '') ='') THEN
		RAISE EXCEPTION 'Parameter pFailedReason must be a non-empty string';
	END IF;

	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Insert the "failed" message record from "staged" message record
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	INSERT INTO public.rabbitmq_failed_messages
	(
		id,
		cid,
		batch_id,
		exchange,
		routing_key,
		delivery_mode,
		content_type,
		reply_to,
		correlation_id,
		priority,
		source_description,
		message,
		batch_message,
		failed_on,
		failed_reason,
		failed_count,
		updated_by,
		updated_on,
		created_by,
		created_on
	)
	SELECT
		id,
		cid,
		batch_id,
		exchange,
		routing_key,
		delivery_mode,
		content_type,
		reply_to,
		correlation_id,
		priority,
		source_description,
		message,
		batch_message,
		NOW() AS failed_on,
		pFailedReason AS failed_reason,
		1 AS failed_count,
		updated_by,
		updated_on,
		created_by,
		created_on
	FROM 
		public.rabbitmq_staged_messages
	WHERE
		id = pId;
		
	DELETE FROM
		public.rabbitmq_staged_messages
	WHERE
		id = pId;
	
	RETURN;
END;

$function$
;

-- DROP FUNCTION public.rabbitmq_pop_messages(int4, int4, varchar, varchar);

CREATE OR REPLACE FUNCTION public.rabbitmq_pop_messages(pcid integer DEFAULT NULL::integer, pmaxmessages integer DEFAULT 10, pexchange character varying DEFAULT NULL::character varying, proutingkey character varying DEFAULT NULL::character varying)
 RETURNS TABLE(id integer, cid integer, batch_id integer, exchange character varying, routing_key character varying, delivery_mode integer, content_type character varying, reply_to character varying, correlation_id character varying, priority integer, source_description text, message jsonb, updated_by integer, updated_on timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
DECLARE	
	BATCH_BY_KEYNAME        TEXT = '_batch_by';
	lStatementStartTime		TIMESTAMP;
	lSql					TEXT;
	lBatchId				INTEGER;
	lStagedMessage			RECORD;
BEGIN
	
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Exclusively lock and fetch a batch of staged messages
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- This function provides a concurrency safe mechanism for RabbitMq publishing script(s) to fetch and
	--  dequeue batches of staged messages. This leverages Postgres locking features to ensure atomic 
	--  behavior such that concurrent processses will always receive mutually exclusive messages, message
	--  records locked by other transactions will never cause blocking and records will properly reappear 
	--  as available in the case of transaction rollback.
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- BATCH-BY FEATURE:
    --  Function supports batched messages by projecting message content into a new JSON object containing
	--  an array of messages and a "batch_by" field indicating what keys the messages were aggregated by.
	--
	--  Example:
	--  {
	--    "batch_by": {"cid": "235", "property_id": "99295"},
	--    "messages": [
	--      {"application_id": "343231", "property_id": "99295", "cid": "235"},
	--      {"application_id": "343232", "property_id": "99295", "cid": "235"},
	--      {"application_id": "343237", "property_id": "99295", "cid": "235"}
	--    ]
	--  }
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	lStatementStartTime := clock_timestamp();
	
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	--  Validate, initialize and sanitize arguments
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	IF (pMaxMessages IS NULL OR pMaxMessages < 1 OR pMaxMessages > 1000) THEN
		RAISE EXCEPTION 'Parameter pMaxMessages must be an integer between 1 and 1000';
	END IF;
	
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	--  Build dynamic SQL to lock and fetch X records matching filters, skipping any already locked
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	SELECT nextval('public.rabbitmq_staged_batches_seq') INTO lBatchId;
     
	DROP TABLE IF EXISTS pg_temp.temp_popped_messages;
    CREATE TEMP TABLE temp_popped_messages AS (
		-- Lock a batch of records matching our criteria, ORDER BY is important so we grab most important/oldest first
		WITH filtered_messages AS (
			SELECT
            	s.cid,
				s.id
			FROM
				public.rabbitmq_staged_messages AS s 
			WHERE
				s.cid = COALESCE(pCid, s.cid)
				AND s.batch_id IS NULL
				AND s.exchange = COALESCE(pExchange, s.exchange)
				AND COALESCE(s.routing_key, '') = COALESCE(pRoutingKey, s.routing_key, '')
			ORDER BY
				s.priority DESC NULLS LAST,
				s.exchange,
				s.routing_key,
				s.id
			FOR UPDATE SKIP LOCKED
			LIMIT pMaxMessages
		),
		
		-- Update the batch_id on our batch and yield all the records
		updated_messages AS (			
			UPDATE
				public.rabbitmq_staged_messages AS s
			SET
				batch_id = lBatchId
			WHERE
				(s.cid, s.id) IN (SELECT f.cid, f.id FROM filtered_messages AS f)	
			RETURNING *
		),
		
		-- Get messages projecting message data into a new JSON object (when we have multiple messages)
		batched_messages AS (
        	SELECT
            	b.id,
            	b.cid,
                b.batch_id,
                b.exchange,
                b.routing_key,
				b.delivery_mode,
				b.content_type,
				b.reply_to,
				b.correlation_id,
				b.priority,
				b.source_description,
				b.message,
				b.updated_by,
				b.updated_on
            FROM
            	updated_messages AS b
        )
        
        SELECT 
        	* 
        FROM 
        	batched_messages
        ORDER BY
			priority DESC NULLS LAST,
			exchange,
			routing_key,
        	id
	);
    
    RETURN QUERY
    SELECT * FROM temp_popped_messages;
        
	RETURN;
END;

$function$
;

-- DROP FUNCTION public.rabbitmq_stage_message(int4, varchar, int4, jsonb, varchar, varchar, varchar, int4, int4, varchar, varchar);

CREATE OR REPLACE FUNCTION public.rabbitmq_stage_message(pcid integer, pexchange character varying, pcompanyuserid integer, pmessage jsonb, psourcedescription character varying DEFAULT NULL::character varying, proutingkey character varying DEFAULT NULL::character varying, pcorrelationid character varying DEFAULT NULL::character varying, ppriority integer DEFAULT NULL::integer, pdeliverymode integer DEFAULT NULL::integer, pcontenttype character varying DEFAULT NULL::character varying, preplyto character varying DEFAULT NULL::character varying)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
	DELIVERY_MODE_PERSISTENT    INTEGER := 2;
	BATCH_BY_WILDCARD           TEXT = '_all';
	BATCH_BY_KEYNAME            TEXT = '_batch_by';
	MAX_BATCH_MESSAGES          INT = 300;
	MAX_MESSAGE_SIZE            INT = 200000;

	lStatementStartTime         TIMESTAMP;
	lBatchingPeer               RECORD;
	lCurMessage                 JSONB;
BEGIN

	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Stage a message destined for RabbitMq
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Insert a message into rabbitmq_staged_messages. This is a staging table for messages destined for
	--  publishing into RabbitMq. Publishing script(s) should execute rabbitmq_pop_messages(...) function
	--  to fetch and dequeue batches of messages in a concurrency safe manner.
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- BATCH-BY FEATURE:
	--  This function includes support for message batching. Prior to staging message, we search for existing
	--  messages having matching message->"_batch_by" and exchange. If found, message is locked and current
	--  JSON message is appended into the batch_message field (JSON array) of the existing record.
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	lStatementStartTime := clock_timestamp();

	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Validate, initialize and sanitize arguments
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	IF (COALESCE(pCid, 0) <= 0) THEN
		RAISE EXCEPTION 'Parameter pCid must be a valid client id';
	ELSIF (COALESCE(pExchange, '') = '') THEN
		RAISE EXCEPTION 'Parameter pExchange must not be empty';
	ELSIF (COALESCE(pCompanyUserId, 0) <= 0) THEN
		RAISE EXCEPTION 'Parameter pCompanyUserId must be valid company user';
	ELSIF (COALESCE(pMessage, '{}'::JSONB) = '{}'::JSONB) THEN
		RAISE EXCEPTION 'Parameter pMessage must be valid, non-empty JSON value';
	ELSIF (NOT COALESCE(pDeliveryMode, 2) = ANY(ARRAY[1,2])) THEN
		RAISE EXCEPTION 'Parameter pDeliveryMode must be 1 (non-persistent) or 2 (persistent)';
	ELSIF (NOT COALESCE(pPriority, 0) BETWEEN 0 AND 10) THEN
		RAISE EXCEPTION 'Parameter pPriority must be an integer from 0 to 10';
	END IF;

	pMessage = pMessage || format( '{"cid": "%s"}', pCid )::JSONB; -- Concatenate cid field into JSON

	-- Drop empty batch-by object
	IF (pMessage->BATCH_BY_KEYNAME = '{}'::JSONB) THEN
		pMessage = pMessage - BATCH_BY_KEYNAME;
	END IF;

	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Check if this message is a duplicate, default appropriately where parameter is NULL
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	IF (EXISTS (
			SELECT 1 FROM public.rabbitmq_staged_messages
			WHERE
				cid = pCid
				AND exchange = pExchange
				AND message = pMessage
				AND COALESCE(routing_key, '') = COALESCE(pRoutingKey, routing_key, '')
				AND COALESCE(reply_to, '') = COALESCE(pReplyTo, reply_to, '')
				AND COALESCE(correlation_id, '') = COALESCE(pCorrelationId, correlation_id, '')
				)) THEN
		RAISE NOTICE 'Message detected as a duplicate and was not staged!';
		RETURN;
	END IF;

	--RAISE NOTICE 'inserting...%, %', length(COALESCE(lBatchingPeer.batch_message::text, '') || pMessage::text), COALESCE(jsonb_array_length(lBatchingPeer.batch_message), 0);
	RAISE NOTICE 'Inserting new staged message';

	INSERT INTO public.rabbitmq_staged_messages
	(
		cid,
		exchange,
		routing_key,
		delivery_mode,
		content_type,
		reply_to,
		correlation_id,
		priority,
		source_description,
		message,
		batch_message,
		updated_by,
		updated_on,
		created_by,
		created_on
	)
	VALUES
	(
		pCid,
		pExchange,
		pRoutingKey,
		COALESCE(pDeliveryMode, DELIVERY_MODE_PERSISTENT),
		COALESCE(pContentType, 'application/json'),
		pReplyTo,
		pCorrelationId,
		pPriority,
		pSourceDescription,
		pMessage,
		CASE WHEN pMessage ? BATCH_BY_KEYNAME THEN format('[%s]', pMessage - BATCH_BY_KEYNAME)::JSONB END,
		pCompanyUserId,
		NOW(),
		pCompanyUserId,
		NOW()
	);

RETURN;
END;

$function$
;

-- DROP FUNCTION public.rabbitmq_trig_stage_message();

CREATE OR REPLACE FUNCTION public.rabbitmq_trig_stage_message()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
	BATCH_BY_WILDCARD           TEXT = '_all';
	BATCH_BY_KEYNAME            TEXT = '_batch_by';

	lCid                        INTEGER;
	lExchange                   VARCHAR;
	lCompanyUserId              INTEGER;
	lSendFields                 JSONB;
	lAliasFields                JSONB;
	lMessagePropertiesOptions   JSONB;
	lBatchByFields              JSONB;
	lStagingCondition           TEXT;
	lSourceDesc                 VARCHAR;

	lStagingConditionParams     TEXT[][] = ARRAY[]::TEXT[];
	lCurParam                   TEXT;
	lStageMessage               BOOLEAN = TRUE;

	lDbData                     JSONB;
	lSendField                  TEXT;
	lAliasField                 TEXT;
	lSendData                   JSONB;
	lMessage                    JSONB;  -- e.g. '{"cid": "235", "property_id": "99295", "application_id": "111111"}'
	lBatchBy                    JSONB;  -- e.g. '{"cid": "235", "property_id": "99295"}'
BEGIN

	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Format the database record and stage it using rabbitmq_stage_message()
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Arguments (via TG_ARGV) :
	--   0: [REQUIRED] (string exchange)                    Exchange name
	--   1: [REQUIRED] (string send_fields)                 JSON array of database table fields to send
	--   2: [OPTIONAL] (string alias_fields)                JSON object of send field aliases to use in message
	--   3: [OPTIONAL] (string message_properties_options)  JSON object of rabbitmq message properties, message options, and/or custom message fields
	--		Keys supported:
	--		{
	--		  "correlation_id":				# Rabittmq message property: correlation_id
	--		  "priority":					#   					 "": priority
	--		  "reply_to":					# 						 "": reply_to
	--		  "omit_trigger_metadata":		# Trigger will include metadata fields about the source unless this is true (DEFAULT=false) : current_database(), TG_TABLE_SCHEMA, TG_TABLE_NAME, and TG_OP
	--		  "extra_data":					# Trigger will merge these static JSON fields into every message
	--		}
	--   4: [OPTIONAL] (string staging_condition)           Parameterized SQL statement with boolean return value (false := do not stage message).
	--                                                        Params should be formatted as #col_name, where col_name is a valid table column found in NEW/OLD.
	--   5: [OPTIONAL] (string batch_by_fields)             JSON array of database table fields to persist to message with batch by keyname (downstream functions will build aggregated messages by aggregating on these fields)
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- TRIGGER USAGE :
	--
	-- EXAMPLE (using WHEN clause filter, aliased fields, staging condition, message properties and batched messages):
	-- ---------------------------------------------------------
	-- CREATE TRIGGER trig_rabbitmq_stage_leadscoring_message
	--   AFTER INSERT OR UPDATE OR DELETE
	--   ON public.applications FOR EACH ROW
	--   WHEN (
	--     COALESCE(NEW.application_stage_id, 1) = ANY(ARRAY[1, 3, 4])
	--     AND COALESCE(NEW.application_status_id, 0) <> ALL(ARRAY[5, 6])
	--     AND COALESCE(OLD.application_status_id, 0) <> COALESCE(NEW.application_status_id, 0)
	--   )
	--   EXECUTE PROCEDURE public.rabbitmq_trig_stage_message(
	--     'leads.leadscoring',
	--     '[ "cid", "property_id", "id" ]',
	--     '{ "id": "application_id" }',
	--     '{ "priority": "2", "correlation_id": "9FE738B6", "omit_trigger_metadata": true } }'
	--     'SELECT EXISTS( SELECT 1 FROM public.company_preferences WHERE cid = #cid AND key = ''ENABLE_LEAD_SCORING'' AND value = ''1'' )',
	--     '[ "cid", "property_id" ]'
	--   );
	--
	-- EXAMPLE (using extra data):
	-- ---------------------------------------------------------
	-- CREATE TRIGGER trig_queue_for_translation
	--   AFTER INSERT OR UPDATE
	--   ON public.add_on_types FOR EACH ROW
	--   EXECUTE PROCEDURE public.rabbitmq_trig_stage_message(
	--     'i18n.system.translations',
	--     '[ "id", "name", "description" ]',
	--     NULL,
	--     '{ extra_data: { "version": 921, "pkey_columns": [ "id" ] } }'
	--   );
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	-- Leverage exception trapping to insulate any failure from impacting insert/update
	BEGIN

		-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		-- Validate, initialize and sanitize arguments
		-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		IF (TG_WHEN <> 'AFTER' OR TG_LEVEL <> 'ROW') THEN
			RAISE NOTICE 'Function may only run as an ROW level AFTER trigger!';
			RETURN NULL;
		ELSIF (COALESCE(TG_ARGV[0], '') = '') THEN
			RAISE NOTICE 'Paramter 0 (exchange) must be supplied!';
			RETURN NULL;
		ELSIF (COALESCE(TG_ARGV[1], '') = '') THEN
			RAISE NOTICE 'Paramter 1 (send fields) must be supplied!';
			RETURN NULL;
		END IF;

		lExchange                   = TG_ARGV[0];
		lSendFields                 = TG_ARGV[1]::JSONB;
		lAliasFields                = COALESCE(NULLIF(TG_ARGV[2], ''), '{}')::JSONB;
		lMessagePropertiesOptions   = COALESCE(NULLIF(TG_ARGV[3], ''), '{}')::JSONB;
		lStagingCondition           = COALESCE(NULLIF(TG_ARGV[4], ''), '');
		lBatchByFields              = COALESCE(NULLIF(TG_ARGV[5], ''), '[]')::JSONB;
		lSourceDesc                 = format('%s trigger %s ON %s.%s', TG_OP, TG_NAME, TG_TABLE_SCHEMA, TG_TABLE_NAME);
		lMessage                    = '{}'::JSONB;
		lBatchBy                    = '{}'::JSONB;

		IF (jsonb_array_length(lSendFields) = 0) THEN
			RAISE NOTICE 'Paramter 1 (send fields) must be a JSON array with at least 1 value!';
			RETURN NULL;
		END IF;

		-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		-- Get database row as JSON
		-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
			lDbData = to_jsonb(NEW.*);
		ELSIF (TG_OP = 'DELETE') THEN
			lDbData = to_jsonb(OLD.*);
		END IF;

		-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		-- Do not stage message if "staging condition" SQL statement returns false
		-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		IF (lStagingCondition <> '') THEN
			-- Parse parameter names from SQL
			SELECT ARRAY( SELECT regexp_matches(
				lStagingCondition,
				E'#[^ ]+',
				'g') ) INTO lStagingConditionParams;

			-- Replace parameter names with column values
			FOREACH lCurParam IN ARRAY lStagingConditionParams LOOP
				lStagingCondition = REPLACE(lStagingCondition, lCurParam, lDbData->>(SUBSTRING(lCurParam FROM 2)));
			END LOOP;

			EXECUTE lStagingCondition INTO lStageMessage;
			IF (NOT lStageMessage) THEN
				RAISE NOTICE 'Paramter 4 (staging condition) returned false! Message staging is skipped!';
				RETURN NULL;
			END IF;
		END IF;

		-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		-- Add a few "system" fields to message regarding what triggered this message, if "omit_trigger_metadata" option NOT true
		-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		IF (NOT COALESCE(lMessagePropertiesOptions->>'omit_trigger_metadata', 'f')::BOOLEAN) THEN
			lMessage = lMessage || format('{"%s": "%s", "%s": "%s", "%s": "%s", "%s": "%s"}', '_db', current_database(), 'TG_TABLE_SCHEMA', TG_TABLE_SCHEMA, 'TG_TABLE_NAME', TG_TABLE_NAME, 'TG_OP', TG_OP)::JSONB;
		END IF;

		-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		-- Add extra data to message
		-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		lMessage = lMessage || COALESCE(lMessagePropertiesOptions->'extra_data', '{}'::JSONB);

		-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		-- Validate send fields, for each send field append the aliased-field/value to the message.
		--  Also append to lBatchBy if field is a batch-by field
		-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		-- TO get the changed columns
		IF( lSendFields ? '_changed' ) THEN
            lSendFields = lSendFields - '_changed';
            IF( TG_OP = 'INSERT' ) THEN
              lSendFields := lSendFields || ( SELECT array_to_json( ARRAY( SELECT * FROM jsonb_object_keys ( row_to_json(NEW.*)::jsonb)) )::jsonb);
            ELSEIF( TG_OP = 'UPDATE' ) THEN
                lSendFields := lSendFields || ( SELECT array_to_json( ARRAY( SELECT * FROM jsonb_object_keys ( util_json_diff_objects(row_to_json(NEW.*)::jsonb, row_to_json(OLD.*)::jsonb))))::jsonb );
            END IF;
        END IF;

		IF (NOT lDbData ?& ARRAY(SELECT jsonb_array_elements_text(lSendFields))::TEXT[]) THEN
			RAISE NOTICE 'Parameter 1 (send fields) contains 1 or more invalid values! Values must be valid column names for table!';
			RETURN NULL;
		END IF;

		FOR lSendField IN SELECT * FROM jsonb_array_elements_text(lSendFields) LOOP
			-- Swap in alias name for field, if one was specified
			lAliasField = COALESCE(lAliasFields->>lSendField, lSendField);
            lSendData = jsonb_build_object(lAliasField, lDbData->>lSendField)::JSONB;
			lMessage = lMessage || lSendData;

			-- If send field is a batch by field, append it to lBatchBy
			IF (lBatchByFields ? lSendField) THEN
				lBatchBy = lBatchBy || lSendData;
			END IF;
		END LOOP;

		-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		-- Validate batch-by fields and append the batch by JSON object to message when appropriate
		-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		IF (jsonb_array_length(lBatchByFields) > 0) THEN
			-- Batch-by fields has wildcard, add wildcard batch-by to message, e.g. {"_batch_by": {"_all": "_all"}}
			IF (lBatchByFields ? BATCH_BY_WILDCARD) THEN
				lMessage = lMessage || format('{"%s": {"%s": "%s"}}', BATCH_BY_KEYNAME, BATCH_BY_WILDCARD, BATCH_BY_WILDCARD)::JSONB;
			-- Else if all batch-by fields are valid send fields, e.g. {"_batch_by": {"cid": "235", "property_id": "99295"}}
			ELSIF (lSendFields ?& ARRAY(SELECT jsonb_array_elements_text(lBatchByFields))::TEXT[] AND lBatchBy <> '{}'::JSONB) THEN
				lMessage = lMessage || format('{"%s": %s}', BATCH_BY_KEYNAME, lBatchBy::TEXT)::JSONB;
			ELSE
				RAISE NOTICE 'Parameter 5 (batch by fields) contains 1 or more invalid values, batch-by object is omitted from message!';
			END IF;
		END IF;

		-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		-- Parse out discreet cid & user needed to stage message
		-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		lCid = COALESCE(lDbData->>'cid', '1')::INTEGER;
		lCompanyUserId = COALESCE(lDbData->>'updated_by', lDbData->>'created_by', '1')::INTEGER;

		-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		-- Call function to stage rabbitmq message into local table
		-- NOTE: A collection of companion rabbitmq_* functions provide an concurrency safe SQL API for
		--       a background daemon(s) to dequeue and dispatch these staged messages to a rabbitmq broker
		-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		RAISE NOTICE 'Staging { cid: %, exchange: %, user: %, messsage: %, props_opts: %, source: % }', lCid, lExchange, lCompanyUserId, lMessage, lMessagePropertiesOptions, lSourceDesc;

		PERFORM public.rabbitmq_stage_message(
			lCid,
			lExchange,
			lCompanyUserId,
			lMessage,
			lSourceDesc,
			current_database()::VARCHAR, -- routing_key
			lMessagePropertiesOptions->>'correlation_id',
			(lMessagePropertiesOptions->>'priority')::INTEGER,
			NULL, -- delivery_mode
			'application/json', -- content_type
			lMessagePropertiesOptions->>'reply_to'
		);

	EXCEPTION WHEN others THEN
		RAISE NOTICE 'rabbitmq_trig_stage_message() failed (error code %) : % ', SQLSTATE, SQLERRM;
	END;

	RETURN NULL;
END;
$function$
;

-- DROP FUNCTION public.rboolop(query_int, _int4);

CREATE OR REPLACE FUNCTION public.rboolop(query_int, integer[])
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$rboolop$function$
;

COMMENT ON FUNCTION public.rboolop(query_int, _int4) IS 'boolean operation with array';

-- DROP FUNCTION public.search_keyword_in_database(text);

CREATE OR REPLACE FUNCTION public.search_keyword_in_database(keyword text)
 RETURNS TABLE(table_name_1 text, column_name_1 text, value text)
 LANGUAGE plpgsql
AS $function$
DECLARE
    table_name_1 text;
    column_name_1 text;
    query text;
BEGIN
    FOR table_name_1, column_name_1 IN
        (SELECT table_name, column_name
         FROM information_schema.columns
         WHERE table_schema = 'public') -- Adjust the schema as needed
    LOOP
        query := format(
            'SELECT * FROM %I WHERE %I::text LIKE $1',
            table_name_1,
            column_name_1
        );
        FOR value IN EXECUTE query USING '%' || keyword || '%'
        LOOP
            RETURN NEXT;
        END LOOP;
    END LOOP;
END;
$function$
;

-- DROP FUNCTION public.set_limit(float4);

CREATE OR REPLACE FUNCTION public.set_limit(real)
 RETURNS real
 LANGUAGE c
 STRICT
AS '$libdir/pg_trgm', $function$set_limit$function$
;

-- DROP FUNCTION public.show_limit();

CREATE OR REPLACE FUNCTION public.show_limit()
 RETURNS real
 LANGUAGE c
 STABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$show_limit$function$
;

-- DROP FUNCTION public.show_trgm(text);

CREATE OR REPLACE FUNCTION public.show_trgm(text)
 RETURNS text[]
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$show_trgm$function$
;

-- DROP FUNCTION public.similarity(text, text);

CREATE OR REPLACE FUNCTION public.similarity(text, text)
 RETURNS real
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$similarity$function$
;

-- DROP FUNCTION public.similarity_dist(text, text);

CREATE OR REPLACE FUNCTION public.similarity_dist(text, text)
 RETURNS real
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$similarity_dist$function$
;

-- DROP FUNCTION public.similarity_op(text, text);

CREATE OR REPLACE FUNCTION public.similarity_op(text, text)
 RETURNS boolean
 LANGUAGE c
 STABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$similarity_op$function$
;

-- DROP FUNCTION public.skeys(hstore);

CREATE OR REPLACE FUNCTION public.skeys(hstore)
 RETURNS SETOF text
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_skeys$function$
;

-- DROP FUNCTION public.slice(hstore, _text);

CREATE OR REPLACE FUNCTION public.slice(hstore, text[])
 RETURNS hstore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_slice_to_hstore$function$
;

-- DROP FUNCTION public.slice_array(hstore, _text);

CREATE OR REPLACE FUNCTION public.slice_array(hstore, text[])
 RETURNS text[]
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_slice_to_array$function$
;

-- DROP FUNCTION public.sort(_int4);

CREATE OR REPLACE FUNCTION public.sort(integer[])
 RETURNS integer[]
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$sort$function$
;

-- DROP FUNCTION public.sort(_int4, text);

CREATE OR REPLACE FUNCTION public.sort(integer[], text)
 RETURNS integer[]
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$sort$function$
;

-- DROP FUNCTION public.sort_asc(_int4);

CREATE OR REPLACE FUNCTION public.sort_asc(integer[])
 RETURNS integer[]
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$sort_asc$function$
;

-- DROP FUNCTION public.sort_desc(_int4);

CREATE OR REPLACE FUNCTION public.sort_desc(integer[])
 RETURNS integer[]
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$sort_desc$function$
;

-- DROP FUNCTION public.strict_word_similarity(text, text);

CREATE OR REPLACE FUNCTION public.strict_word_similarity(text, text)
 RETURNS real
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$strict_word_similarity$function$
;

-- DROP FUNCTION public.strict_word_similarity_commutator_op(text, text);

CREATE OR REPLACE FUNCTION public.strict_word_similarity_commutator_op(text, text)
 RETURNS boolean
 LANGUAGE c
 STABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$strict_word_similarity_commutator_op$function$
;

-- DROP FUNCTION public.strict_word_similarity_dist_commutator_op(text, text);

CREATE OR REPLACE FUNCTION public.strict_word_similarity_dist_commutator_op(text, text)
 RETURNS real
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$strict_word_similarity_dist_commutator_op$function$
;

-- DROP FUNCTION public.strict_word_similarity_dist_op(text, text);

CREATE OR REPLACE FUNCTION public.strict_word_similarity_dist_op(text, text)
 RETURNS real
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$strict_word_similarity_dist_op$function$
;

-- DROP FUNCTION public.strict_word_similarity_op(text, text);

CREATE OR REPLACE FUNCTION public.strict_word_similarity_op(text, text)
 RETURNS boolean
 LANGUAGE c
 STABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$strict_word_similarity_op$function$
;

-- DROP FUNCTION public.subarray(_int4, int4);

CREATE OR REPLACE FUNCTION public.subarray(integer[], integer)
 RETURNS integer[]
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$subarray$function$
;

-- DROP FUNCTION public.subarray(_int4, int4, int4);

CREATE OR REPLACE FUNCTION public.subarray(integer[], integer, integer)
 RETURNS integer[]
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$subarray$function$
;

-- DROP FUNCTION public.svals(hstore);

CREATE OR REPLACE FUNCTION public.svals(hstore)
 RETURNS SETOF text
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/hstore', $function$hstore_svals$function$
;

-- DROP FUNCTION public.sym_largeobject(oid);

CREATE OR REPLACE FUNCTION public.sym_largeobject(objectid oid)
 RETURNS text
 LANGUAGE plpgsql
AS $function$                                                                                                                                            DECLARE                                                                                                                                                                                                  encodedBlob text;                                                                                                                                                                                      encodedBlobPage text;                                                                                                                                                                                BEGIN                                                                                                                                                                                                    encodedBlob := '';                                                                                                                                                                                     FOR encodedBlobPage IN SELECT pg_catalog.encode(data, 'escape')                                                                                                                                                   FROM pg_largeobject WHERE loid = objectId ORDER BY pageno LOOP                                                                                                                                           encodedBlob := encodedBlob || encodedBlobPage;                                                                                                                                                       END LOOP;                                                                                                                                                                                              RETURN pg_catalog.encode(pg_catalog.decode(encodedBlob, 'escape'), 'base64');                                                                                                                                              EXCEPTION WHEN OTHERS THEN                                                                                                                                                                               RETURN '';                                                                                                                                                                                           END                                                                                                                                                                                                    $function$
;

-- DROP FUNCTION public.sym_node_disabled();

CREATE OR REPLACE FUNCTION public.sym_node_disabled()
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$                                                                                                                                                     DECLARE                                                                                                                                                                                                  nodeId VARCHAR(50);                                                                                                                                                                                  BEGIN                                                                                                                                                                                                    select current_setting('symmetric.node_disabled') into nodeId;                                                                                                                                         return nodeId;                                                                                                                                                                                       EXCEPTION WHEN OTHERS THEN                                                                                                                                                                               return '';                                                                                                                                                                                           END;                                                                                                                                                                                                   $function$
;

-- DROP FUNCTION public.sym_triggers_disabled();

CREATE OR REPLACE FUNCTION public.sym_triggers_disabled()
 RETURNS integer
 LANGUAGE plpgsql
AS $function$                                                                                                                                                     DECLARE                                                                                                                                                                                                  triggerDisabled INTEGER;                                                                                                                                                                             BEGIN                                                                                                                                                                                                    select current_setting('symmetric.triggers_disabled') into triggerDisabled;                                                                                                                            return triggerDisabled;                                                                                                                                                                              EXCEPTION WHEN OTHERS THEN                                                                                                                                                                               return 0;                                                                                                                                                                                            END;                                                                                                                                                                                                   $function$
;

-- DROP FUNCTION public.tconvert(text, text);

CREATE OR REPLACE FUNCTION public.tconvert(text, text)
 RETURNS hstore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE
AS '$libdir/hstore', $function$hstore_from_text$function$
;

-- DROP FUNCTION public.unaccent(regdictionary, text);

CREATE OR REPLACE FUNCTION public.unaccent(regdictionary, text)
 RETURNS text
 LANGUAGE c
 STABLE PARALLEL SAFE STRICT
AS '$libdir/unaccent', $function$unaccent_dict$function$
;

-- DROP FUNCTION public.unaccent(text);

CREATE OR REPLACE FUNCTION public.unaccent(text)
 RETURNS text
 LANGUAGE c
 STABLE PARALLEL SAFE STRICT
AS '$libdir/unaccent', $function$unaccent_dict$function$
;

-- DROP FUNCTION public.unaccent_init(internal);

CREATE OR REPLACE FUNCTION public.unaccent_init(internal)
 RETURNS internal
 LANGUAGE c
 PARALLEL SAFE
AS '$libdir/unaccent', $function$unaccent_init$function$
;

-- DROP FUNCTION public.unaccent_lexize(internal, internal, internal, internal);

CREATE OR REPLACE FUNCTION public.unaccent_lexize(internal, internal, internal, internal)
 RETURNS internal
 LANGUAGE c
 PARALLEL SAFE
AS '$libdir/unaccent', $function$unaccent_lexize$function$
;

-- DROP FUNCTION public.uniq(_int4);

CREATE OR REPLACE FUNCTION public.uniq(integer[])
 RETURNS integer[]
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/_int', $function$uniq$function$
;

-- DROP PROCEDURE public.update_cached_field_of_gl_details(int4, numeric);

CREATE OR REPLACE PROCEDURE public.update_cached_field_of_gl_details(IN lbatchsize integer, IN lsleepduration numeric)
 LANGUAGE plpgsql
AS $procedure$

DECLARE
	lMinGlHeaderId			INT;
	lMaxGlHeaderId			INT;
	lLoopNumber				INT;
	lMaxLoopNumber			INT;
	lAffectedRows			INT;

BEGIN
	
    lLoopNumber		:= 0;
	lAffectedRows	:= 0;
	
	SELECT MIN( gl_header_id ) INTO lMinGlHeaderId FROM gl_details WHERE cached_gh_post_date IS NULL;
	SELECT MAX( gl_header_id ) INTO lMaxGlHeaderId FROM gl_details;

	lMaxLoopNumber	:= round( ( lMaxGlHeaderId - lMinGlHeaderId )::numeric / lBatchSize ) + 1; /* extra loop as a buffer */

	LOOP

		UPDATE
			gl_details AS gd
		SET
			cached_gh_post_date = gh.cached_gh_post_date,
			cached_gh_transaction_datetime = gh.cached_gh_transaction_datetime,
			cached_gh_gl_header_status_type_id = gh.cached_gh_gl_header_status_type_id,
			cached_gh_gl_book_id = gh.cached_gh_gl_book_id,
			cached_gh_offsetting_gl_header_id = gh.cached_gh_offsetting_gl_header_id,
			cached_gh_header_number = gh.cached_gh_header_number,
			cached_gh_reference_id = gh.cached_gh_reference_id,
			cached_gh_reference = gh.cached_gh_reference,
			cached_gh_memo = gh.cached_gh_memo,
			cached_gh_is_template = gh.cached_gh_is_template
		FROM
			gl_headers AS gh
		WHERE
			gd.cid = gh.cid
			AND gd.gl_header_id = gh.id
			AND gh.id BETWEEN
				lMinGlHeaderId + lBatchSize * lLoopNumber AND
				lMinGlHeaderId + lBatchSize * ( lLoopNumber + 1 );

		GET DIAGNOSTICS lAffectedRows = ROW_COUNT;

		IF( lAffectedRows > 0 ) THEN
			COMMIT;
			PERFORM pg_sleep( lSleepDuration );
		END IF;

		EXIT WHEN lLoopNumber > lMaxLoopNumber;
		lLoopNumber := lLoopNumber + 1;

	END LOOP;
	COMMIT;
END;
$procedure$
;

-- DROP PROCEDURE public.update_cached_fields_of_gl_details(int4, int4, numeric);

CREATE OR REPLACE PROCEDURE public.update_cached_fields_of_gl_details(IN lclientid integer, IN lbatchsize integer, IN lsleepduration numeric)
 LANGUAGE plpgsql
AS $procedure$

DECLARE
	lMinGlHeaderId			INT;
	lMaxGlHeaderId			INT;
	lLoopNumber				INT DEFAULT 0;
	lMaxLoopNumber			INT;
	lAffectedRows			INT DEFAULT 0;

BEGIN

	SELECT MIN( gl_header_id ) INTO lMinGlHeaderId FROM gl_details WHERE cached_gh_post_date IS NULL;
	SELECT MAX( gl_header_id ) INTO lMaxGlHeaderId FROM gl_details;

	lMaxLoopNumber	:= round( ( lMaxGlHeaderId - lMinGlHeaderId )::numeric / lBatchSize ) + 1; /* extra loop as a buffer */

	LOOP

		UPDATE
			gl_details AS gd
		SET
			cached_gh_post_date = gh.post_date,
			cached_gh_transaction_datetime = gh.transaction_datetime,
			cached_gh_gl_header_status_type_id = gh.gl_header_status_type_id,
			cached_gh_gl_book_id = gh.gl_book_id,
			cached_gh_offsetting_gl_header_id = gh.offsetting_gl_header_id,
			cached_gh_header_number = gh.header_number,
			cached_gh_reference_id = gh.reference_id,
			cached_gh_reference = gh.reference,
			cached_gh_memo = gh.memo,
			cached_gh_is_template = gh.is_template
		FROM
			gl_headers AS gh
		WHERE
			gh.cid = lClientId
			AND gd.cid = gh.cid
			AND gd.gl_header_id = gh.id
			AND gd.cached_gh_post_date IS NULL
			AND gh.id BETWEEN
				lMinGlHeaderId + lBatchSize * lLoopNumber AND
				lMinGlHeaderId + lBatchSize * ( lLoopNumber + 1 );

		GET DIAGNOSTICS lAffectedRows = ROW_COUNT;

		IF( lAffectedRows > 0 ) THEN
			PERFORM pg_sleep( lSleepDuration );
		END IF;

		EXIT WHEN lLoopNumber > lMaxLoopNumber;
		lLoopNumber := lLoopNumber + 1;

	END LOOP;
END;
$procedure$
;

-- DROP FUNCTION public.util_add_percent(int4, float8);

CREATE OR REPLACE FUNCTION public.util_add_percent(pinput integer, ppercent double precision)
 RETURNS integer
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
BEGIN
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- Utility function to add a percentage to a number
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	return round(util_add_percent(pInput::numeric, pPercent::numeric))::int;
END;
$function$
;

-- DROP FUNCTION public.util_add_percent(int4, numeric);

CREATE OR REPLACE FUNCTION public.util_add_percent(pinput integer, ppercent numeric)
 RETURNS integer
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
BEGIN
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- Utility function to add a percentage to a number
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	return round(util_add_percent(pInput::numeric, pPercent))::int;
END;
$function$
;

-- DROP FUNCTION public.util_add_percent(numeric, float8);

CREATE OR REPLACE FUNCTION public.util_add_percent(pinput numeric, ppercent double precision)
 RETURNS numeric
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
BEGIN
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- Utility function to add a percentage to a number
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	return util_add_percent(pInput, pPercent::numeric);
END;
$function$
;

-- DROP FUNCTION public.util_add_percent(numeric, numeric);

CREATE OR REPLACE FUNCTION public.util_add_percent(pinput numeric, ppercent numeric)
 RETURNS numeric
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
BEGIN
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- Utility function to add a percentage to a number
	-- EXAMPLE : select util_add_percent(220.5, -0.10); -- 198.45
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	return pInput + (pInput * pPercent);
END;
$function$
;

-- DROP FUNCTION public.util_array_diff(_text, _text);

CREATE OR REPLACE FUNCTION public.util_array_diff(pleft text[], pright text[])
 RETURNS text[]
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
DECLARE
	lDiff TEXT[];
BEGIN
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Utility function return difference in the 2 arrays: pLeft - pRight. 
	--  Remove from pLeft what is also in pRight and return the result
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- PARAMETERS :
	--   pLeft       : Left hand array operand
	--   pRight      : Right hand array operand
	-- RETURNS : 
	--   TEXT        : Array representing the difference
	-- EXAMPLES :
	--   SELECT util_array_diff( ARRAY[12,3,5,7,8]::TEXT[], ARRAY[3,7,8]::TEXT[] ); 				-- RETURNS: {5,12}
	--   SELECT util_array_diff( '{red,green,blue,pink}'::TEXT[], '{red,green,black}'::TEXT[] ); 	-- RETURNS: {blue,pink}
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	-- * Validate input
	IF (pLeft IS NULL) THEN 
		RETURN '{}'::TEXT[];
	END IF;
	
	IF (pRight IS NULL) THEN 
		RETURN pLeft;
	END IF;
	
	SELECT 
		array_agg(val)
	INTO
		lDiff
	FROM (
	  SELECT unnest(pLeft)
	  EXCEPT
	  SELECT unnest(pRight)
	) t(val);
		
	RETURN lDiff;
END;
$function$
;

-- DROP FUNCTION public.util_dependency_tree(_text);

CREATE OR REPLACE FUNCTION public.util_dependency_tree(object_names text[])
 RETURNS TABLE(dependency_tree text, object_identity text, object_type text)
 LANGUAGE sql
 SECURITY DEFINER
AS $function$
WITH target AS (
  SELECT objid, dependency_chain
  FROM view_util_table_dependency_tree
  JOIN unnest(object_names) AS target(objname) ON objid = objname::regclass
)
, list AS (
  SELECT DISTINCT
    format('%*s%s %s', -4*level
          , CASE WHEN object_identity = ANY(object_names) THEN '*' END
          , object_type, object_identity
    ) AS dependency_tree,object_identity,object_type
  , dependency_sort_chain
  FROM target
  JOIN view_util_table_dependency_tree util
    ON util.objid = ANY(target.dependency_chain) -- root-bound chain
    OR target.objid = ANY(util.dependency_chain) -- leaf-bound chain
)
SELECT dependency_tree,object_identity,object_type FROM list
ORDER BY dependency_sort_chain;
$function$
;

-- DROP FUNCTION public.util_drop_functions(text, text);

CREATE OR REPLACE FUNCTION public.util_drop_functions(pfunctionname text, pschema text DEFAULT 'public'::text)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE
	lSql         TEXT = '';
	lDropSql     TEXT = '';
	lProcCount   INTEGER = 0;
	lPgProc      RECORD;
BEGIN
	lSql := $$
		SELECT 
			n.nspname,
			p.proname AS procname,
			pg_catalog.pg_get_function_identity_arguments( p.oid ) AS procargs
		FROM 
			pg_proc p
			JOIN pg_namespace n ON p.pronamespace = n.oid 
		WHERE 
			p.proname = $1 
			AND n.nspname = $2$$;
			
	FOR lPgProc IN EXECUTE( lSql ) USING pFunctionName, pSchema LOOP
		lDropSql := format($$DROP FUNCTION %I.%I( %s )$$, lPgProc.nspname, lPgProc.procname, lPgProc.procargs );
		
		RAISE NOTICE '%', lDropSql;
		EXECUTE lDropSql;
		
		lProcCount := lProcCount + 1;
	END LOOP;
	
	IF ( lProcCount <= 0 ) THEN
		RAISE NOTICE 'No function(s) exist with name: %.%', pSchema, pFunctionName;
	END IF;
	
	RETURN lProcCount;
END
$function$
;

-- DROP FUNCTION public.util_get_constraint_def(text, text, text, bool, text);

CREATE OR REPLACE FUNCTION public.util_get_constraint_def(namespace text, table_name text, constraint_name text, template boolean DEFAULT false, parent_table_name text DEFAULT NULL::text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
  ldefination_format text :='ALTER TABLE %1$s.%2$s ADD CONSTRAINT %3$s %4$s';
BEGIN
    RETURN
            format(
                ldefination_format,
                namespace,
                CASE
                     WHEN template
                     THEN '%1s '
                     ELSE pgc.relname
                END,
                CASE
                     WHEN template
                     THEN '%2s'
                     ELSE pc.conname END,
                CASE
                     WHEN template AND pgc.relname = parent_table_name
                     THEN
                         CASE
                              WHEN parent_table_name = (SELECT
                                        *
                                    FROM
                                        (
                                          SELECT
                                              (regexp_matches ( pg_catalog.pg_get_constraintdef ( pc.oid, TRUE ), E'REFERENCES (\\w+\\.)?(\\w+)' )
                                        ) [ 2 ] ) t(refname) )
                              THEN regexp_replace(pg_catalog.pg_get_constraintdef ( pc.oid, TRUE ), E'REFERENCES (\\w+\\.)?(\\w+)', E'REFERENCES \\1%3s')
                              ELSE regexp_replace(pg_catalog.pg_get_constraintdef ( pc.oid, TRUE ), E'REFERENCES (\\w+\\.)?(\\w+)', E'REFERENCES \\1\\2')
                         END
                     WHEN template
                     THEN regexp_replace(pg_catalog.pg_get_constraintdef ( pc.oid, TRUE ), E'REFERENCES (\\w+\\.)?(\\w+)', E'REFERENCES \\1%3s')
                     ELSE pg_catalog.pg_get_constraintdef ( pc.oid, TRUE )
               END
            )  as defination
        FROM
            pg_catalog.pg_constraint pc
            JOIN pg_catalog.pg_namespace ns on ( ns.oid =  pc.connamespace )
            JOIN pg_catalog.pg_class pgc ON ( pgc.oid = pc.conrelid )
        WHERE
            pc.conname = constraint_name
            and ns.nspname = namespace
           AND pgc.relname = table_name;
END;
$function$
;

-- DROP FUNCTION public.util_get_index_def(text, text, text, bool);

CREATE OR REPLACE FUNCTION public.util_get_index_def(namespace text, table_name text, index_name text, template boolean DEFAULT false)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN
            CASE
             WHEN template
             THEN regexp_replace( regexp_replace(
                                  pg_get_indexdef ( indexrelid )
                                  , E'(?i)\\w+(?=\\s+on\\s+)'
                                  , '%1s' )
                                  , E'(?i)\\w+(?=\\s+USING\\s+)'
                                  , '%2s' )
             ELSE pg_get_indexdef ( indexrelid )
            END
        FROM
            pg_catalog.pg_index pc
            JOIN pg_catalog.pg_class pgc ON ( pgc.oid = pc.indrelid )
            JOIN pg_catalog.pg_class pgc2 ON ( pgc2.oid = pc.indexrelid )
            JOIN pg_catalog.pg_namespace ns ON ( ns.oid = pgc.relnamespace )
        WHERE
            pgc.relname = table_name
            AND ns.nspname = namespace
            AND pgc2.relname = index_name;
END;
$function$
;

-- DROP FUNCTION public.util_get_system_translated(text, text, jsonb, text);

CREATE OR REPLACE FUNCTION public.util_get_system_translated(pcolumnname text, pcolumnvalue text, pdetails jsonb, plocalecode text DEFAULT NULL::text)
 RETURNS text
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
	lResult                   TEXT;
BEGIN
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Utility function to extract locale translation for a column in a system translated table
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- PARAMETERS :
	--   pColumnName      : Column name
	--   pColumnValue     : Raw column value
	--   pDetails         : Details field from row (should contain "_translated")
	--   pLocaleCode      : [OPTIONAL] Override locale code from current_setting
	-- RETURNS : 
	--   TEXT              : Translated value  for column
	-- EXAMPLES :
	--   SELECT util_set_locale( 'es_MX', 'en_US'); -- util_set_locale() should be called first 
	--   SELECT util_get_system_translated( 'name', 'Services', '{"_translated": {"es_MX": {"building_name": "Edificio 1"}}}'::jsonb );      -- RETURNS: Edificio 1
	--   SELECT util_get_system_translated( 'name', 'Building 1', '{"_translated": {"fr_FR": {"building_name": "Btiment 1"}}}'::jsonb );    -- RETURNS: Building 1 (coalesces to column value)
	-- 
	--   SELECT util_set_locale( 'en_US', 'zh_CN'); 
	--   SELECT util_get_system_translated( 'name', 'Building 1', '{"_translated": {"en_US": {"building_name": "Building 1xxx"}}}'::jsonb ); -- RETURNS: Building 1 (for en_US we always return the discreet column value)
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	RETURN public.util_get_translated(pColumnName, pColumnValue, pDetails, pLocaleCode, true);
END;
$function$
;

-- DROP FUNCTION public.util_get_table_structure(text, text, json, bool, bool, bool);

CREATE OR REPLACE FUNCTION public.util_get_table_structure(pschema text, ptable text, pcolumnorders json, pcomments boolean DEFAULT false, ppermission boolean DEFAULT false, ptemplate boolean DEFAULT false)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
	v_table_ddl   TEXT;
	column_record RECORD;
	lTempSQL      TEXT;
BEGIN

	DROP TABLE IF EXISTS pg_temp.column_order_json;
	CREATE TEMP TABLE column_order_json AS (

		with column_metadata as (
			SELECT
				attname,
				pa.attnum,
				new_order.after AS new_order_after,
				new_order.column_name AS new_order_col,
				new_order.order_num_overhead
			FROM
				pg_attribute pa
				JOIN pg_class pc ON ( pa.attrelid = pc.oid )
				JOIN pg_namespace pn ON pn.oid = pc.relnamespace
				LEFT JOIN
				(
					SELECT
						0.0001 * row_number ( ) over ( ) AS order_num_overhead,
						KEY AS column_name,
						COALESCE( substring ( value::TEXT, E'\->(\\w+)' ), '-1'::text ) AS AFTER
					FROM
						json_each ( (pColumnOrders) )
				) AS new_order ON new_order.column_name = pa.attname
			WHERE
				pc.relname = pTable
				and pa.attisdropped='f'
				and pn.nspname = pSchema
				AND pa.attnum > 0)

		SELECT
			cm.attname as column_name,
			ROW_NUMBER ( ) over ( ORDER BY (case when cm.new_order_after = '-1' then -1000 else 0 end ) + coalesce ( cm2.attnum, cm.attnum ) + coalesce ( cm.order_num_overhead, 0 ) ) AS column_order,
            cm.new_order_after
		FROM
			column_metadata cm
			LEFT JOIN column_metadata cm2 ON ( cm.new_order_after = cm2.attname )

		--select distinct on (key) key::text as column_name, value::text::int as column_order from json_each(column_orders)

	);

    FOR column_record in
      SELECT
          key
      FROM
          json_each ( ( pColumnOrders ) )
    LOOP
        UPDATE column_order_json coj
          SET
              column_order = o.order_num
          FROM
              (
                SELECT
                    coj.column_name,
                    row_number() over ( ORDER BY COALESCE ( coj2.column_order + 1, coj.column_order ) ) AS order_num
                FROM
                    column_order_json coj
                    LEFT JOIN column_order_json coj2 ON coj2.column_name = coj.new_order_after
              ) o
          WHERE
              coj.column_name = o.column_name
              AND coj.column_order <> o.order_num;
    END LOOP;

	FOR column_record IN
	SELECT
		b.nspname as schema_name,
		b.relname as table_name,
		a.attname as column_name,
		coj.column_order,
		pg_catalog.format_type(a.atttypid, a.atttypmod) as column_type,
		CASE WHEN
			(SELECT substring(pg_catalog.pg_get_expr(d.adbin, d.adrelid) for 128)
			 FROM pg_catalog.pg_attrdef d
			 WHERE d.adrelid = a.attrelid AND d.adnum = a.attnum AND a.atthasdef) IS NOT NULL THEN
			'DEFAULT '|| (SELECT substring(pg_catalog.pg_get_expr(d.adbin, d.adrelid) for 128)
			              FROM pg_catalog.pg_attrdef d
			              WHERE d.adrelid = a.attrelid AND d.adnum = a.attnum AND a.atthasdef)
		ELSE
			''
		END as column_default_value,
		CASE WHEN a.attnotnull = true THEN
			'NOT NULL'
		ELSE
			'NULL'
		END as column_not_null,
		a.attnum as attnum,
		e.max_attnum as max_attnum
	FROM
		pg_catalog.pg_attribute a
		INNER JOIN
		(
			SELECT
				c.oid,
				n.nspname,
				c.relname
			FROM
				pg_catalog.pg_class c
				LEFT JOIN
				pg_catalog.pg_namespace n
				ON n.oid = c.relnamespace
			WHERE
				c.relname ~ ( '^(' || pTable || ')$' )
				AND pg_catalog.pg_table_is_visible( c.oid )
			ORDER BY
				2,
				3 ) b
		ON a.attrelid = b.oid
		INNER JOIN
		(
			SELECT
				a.attrelid,
				max( a.attnum ) AS max_attnum
			FROM
				pg_catalog.pg_attribute a
			WHERE
				a.attnum > 0
				AND NOT a.attisdropped
			GROUP BY
				a.attrelid ) e
		ON a.attrelid = e.attrelid
		JOIN
		column_order_json coj
		ON ( coj.column_name = a.attname )
	WHERE
		a.attnum > 0
		AND NOT a.attisdropped
		AND b.nspname = pSchema
	ORDER BY
		coj.column_order
	LOOP
		IF column_record.column_order = 1 THEN
			v_table_ddl:='CREATE TABLE '||column_record.schema_name||'.'|| CASE WHEN pTemplate THEN '%1s' ELSE column_record.table_name END ||' (';
		ELSE
			v_table_ddl:=v_table_ddl||',';
		END IF;

		IF column_record.column_order <= column_record.max_attnum THEN
			v_table_ddl:=v_table_ddl||chr(10)||
			             '    '||column_record.column_name||' '||column_record.column_type||' '||column_record.column_default_value||' '||column_record.column_not_null;
		END IF;
	END LOOP;

	IF ( pTemplate ) THEN
		-- v_table_ddl:= replace(v_table_ddl, table_name||'_id_seq', '{table_name}_id_seq');
		v_table_ddl:= regexp_replace( v_table_ddl, 'integer DEFAULT nextval.+?(?=,)', 'SERIAL' );
		v_table_ddl:= regexp_replace( v_table_ddl, 'biginteger DEFAULT nextval.+?(?=,)', 'BIGSERIAL' );
		v_table_ddl:= regexp_replace( v_table_ddl, 'bigint DEFAULT nextval.+?(?=,)', 'BIGSERIAL' );
	END IF;

	v_table_ddl:= v_table_ddl || E');\n';
	--Append comments on table
	SELECT
		'COMMENT ON TABLE ' || pn.nspname || '.%1$s IS ' || quote_literal( obj_description( pgc.OID ) ) || E';\n' AS table_comment_sql
	INTO lTempSQL
	FROM
		pg_class pgc
		JOIN
		pg_namespace pn
		ON pn.oid = pgc.relnamespace
	WHERE
		relkind = 'r'
		AND relname = pTable
		AND nspname = pSchema
		AND pComments = TRUE;

	v_table_ddl := v_table_ddl || COALESCE( lTempSQL, '' ) || E'\n';

	--Append comments on table columns
	SELECT
		array_to_string( array_agg( col_comment_sql ), E';\n' )
	INTO lTempSQL
	FROM
		(
			SELECT
				'COMMENT ON COLUMN ' || pn.nspname || '.%1$s.' || a.attname || ' IS ' || quote_literal( com.description ) AS col_comment_sql
			FROM
				pg_attribute a
				JOIN
				pg_class pgc
				ON pgc.oid = a.attrelid
				JOIN
				pg_namespace pn
				ON pn.oid = pgc.relnamespace
				JOIN
				pg_description com
				ON ( pgc.oid = com.objoid AND a.attnum = com.objsubid )
			WHERE
				a.attnum > 0
				AND pgc.oid = a.attrelid
				AND NOT a.attisdropped
				AND pgc.relname = pTable
				AND pn.nspname = pSchema
				AND pComments = TRUE ) AS sub_query;

	v_table_ddl := v_table_ddl || COALESCE( lTempSQL, '' ) || E';\n';

	--Append permissions
	SELECT
		array_to_string( array_agg( permission_sql ), E';\n' )
	INTO lTempSQL
	FROM
		(
			SELECT
				'GRANT ' || array_to_string( array_agg( privilege_type :: TEXT ), ', ' ) || ' ON ' || pSchema || '.%1$s TO ' || '"' || grantee || '"' AS permission_sql
			FROM
				information_schema.role_table_grants
			WHERE
				table_name = pTable
				AND table_schema = pSchema
				AND pPermission = TRUE
			GROUP BY
				grantee,
				pTable,
				table_schema ) AS sub_query;

	v_table_ddl := v_table_ddl || COALESCE( lTempSQL, '' ) || E';\n';


	RETURN v_table_ddl;
END;

$function$
;

-- DROP FUNCTION public.util_get_translated(text, text, jsonb, text, bool);

CREATE OR REPLACE FUNCTION public.util_get_translated(pcolumnname text, pcolumnvalue text, pdetails jsonb, plocalecode text DEFAULT NULL::text, pissystemtable boolean DEFAULT false)
 RETURNS text
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
	LOCALE_CODE_DEFAULT       TEXT = 'en_US';
	TRANSLATED_DETAILS_KEY    TEXT= '_translated';
	lDefaultLocaleCode        TEXT;
	lAcceptMachineTranslated  BOOL;
	lFuzzyLocaleCode          TEXT;
	lCurLocaleCode            TEXT;
	lAliasLocaleCode          TEXT;
	lResult                   TEXT;
BEGIN
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Utility function to extract locale translation for a specified column from JSON details
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- PARAMETERS :
	--   pColumnName      : Column name
	--   pColumnValue     : Raw column value
	--   pDetails         : Details field from row (should contain "_translated")
	--   pLocaleCode      : [OPTIONAL] Override locale code from current_setting
	--   pIsSystemTable   : [OPTIONAL] Flag to indicate this is getting a translated value for a system table (handling the several unique properties of system table)
	-- RETURNS :
	--   TEXT              : Translated value  for column
	-- EXAMPLES :
	--   SELECT util_set_locale( 'es_MX', 'en_US'); -- util_set_locale() should be called first
	--   SELECT util_get_translated( 'building_name', 'Building 1', '{"_translated": {"es_MX": {"building_name": "Edificio 1"}}}'::jsonb );    -- RETURNS: Edificio 1
	--   SELECT util_get_translated( 'building_name', 'Building 1', '{"_translated": {"es_PE": {"building_name": "Edificiooo 1"}}}'::jsonb );  -- RETURNS: Edificiooo 1 (coalesces to "fuzzy" matched es_PE translation)
	--   SELECT util_get_translated( 'building_name', 'Building 1', '{"_translated": {"fr_FR": {"building_name": "Btiment 1"}}}'::jsonb );    -- RETURNS: Building 1 (coalesces to column value)
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	-- * Validate input
	IF( COALESCE( pColumnName, '' ) = '' OR pDetails IS NULL ) THEN
		RETURN pColumnValue;
	END IF;

	-- * In order of precedence, coalesce to desired locale: param-locale, setting-target (if not ignored), setting-locale
	SELECT COALESCE(
		pLocaleCode,
		CASE WHEN NOT pIsSystemTable THEN NULLIF( current_setting('ent.target_locale_code', TRUE), '' ) END,
		NULLIF( current_setting('ent.locale_code', TRUE), '' )
	) INTO pLocaleCode;

	SELECT current_setting('ent.default_locale_code', TRUE) INTO lDefaultLocaleCode;
	SELECT COALESCE(NULLIF(current_setting('ent.accept_machine_translated', TRUE), ''), 'false')::BOOL INTO lAcceptMachineTranslated;

	IF( pLocaleCode = current_setting('ent.locale_code', TRUE) ) THEN
		SELECT current_setting('ent.alias_locale_code', TRUE) INTO lAliasLocaleCode;
	END IF;

	-- * Calculate fuzzy locale: first translated locale w/ matching language which has value for column
	FOR lCurLocaleCode IN SELECT * FROM jsonb_object_keys(pDetails->TRANSLATED_DETAILS_KEY) LOOP
		IF (pLocaleCode != lCurLocaleCode AND substr(pLocaleCode, 1, 2) = substr(lCurLocaleCode, 1, 2 ) AND COALESCE(pDetails->TRANSLATED_DETAILS_KEY->lCurLocaleCode->>pColumnName, '') != '' AND lCurLocaleCode NOT LIKE '%.machine') THEN
			lFuzzyLocaleCode = lCurLocaleCode;
			EXIT;
		END IF;
	END LOOP;

	-- * Return extracted translated value
	lResult = CASE
		WHEN pLocaleCode = LOCALE_CODE_DEFAULT THEN pColumnValue
		ELSE COALESCE(
			NULLIF(pDetails->TRANSLATED_DETAILS_KEY->pLocaleCode->>pColumnName, ''),
			CASE WHEN lAcceptMachineTranslated THEN
				NULLIF(pDetails->TRANSLATED_DETAILS_KEY->(pLocaleCode || '.machine')->>pColumnName, '') END,
			NULLIF(pDetails->TRANSLATED_DETAILS_KEY->lAliasLocaleCode->>pColumnName, ''),
			NULLIF(pDetails->TRANSLATED_DETAILS_KEY->lFuzzyLocaleCode->>pColumnName, ''),
			CASE WHEN NOT pIsSystemTable OR lDefaultLocaleCode <> LOCALE_CODE_DEFAULT THEN
				NULLIF(pDetails->TRANSLATED_DETAILS_KEY->lDefaultLocaleCode->>pColumnName, '') END,
			pColumnValue
		)
	END;

	RETURN lResult;
END;
$function$
;

-- DROP FUNCTION public.util_get_trigger_def(text, text, text, bool);

CREATE OR REPLACE FUNCTION public.util_get_trigger_def(namespace text, table_name text, ptrigger_name text, template boolean DEFAULT false)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN
            'CREATE TRIGGER '
            || CASE WHEN template THEN '%1s' ELSE trigger_name END
            || ' '
            || action_timing || ' '
            || array_to_string ( array_agg ( event_manipulation::text ), ' OR ' )
            || ' ON '
            || event_object_schema || '.' || CASE WHEN template THEN '%2s' ELSE event_object_table END
            || ' FOR EACH '
            || action_orientation || ' ' || action_statement
        FROM
            information_schema.triggers
        WHERE
            trigger_schema NOT IN ( 'pg_catalog', 'information_schema' )
            AND event_object_table = table_name
            AND event_object_schema = namespace
            AND trigger_name = ptrigger_name
        GROUP BY
            trigger_name,
            action_timing,
            action_orientation,
            action_statement,
            event_object_table,
            event_object_schema;
END;
$function$
;

-- DROP FUNCTION public.util_get_view_def(text, text, bool);

CREATE OR REPLACE FUNCTION public.util_get_view_def(namespace text, view_name text, template boolean DEFAULT false)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN
            'CREATE OR REPLACE VIEW '
            || schemaname  || '.'
            || CASE WHEN template THEN '%1s' ELSE view_name END
            || ' AS '
            || ' ( '
            ||  regexp_replace(definition, ';$','')
            || ' ) '
        FROM
            pg_views pv
        WHERE
            pv.schemaname = namespace
            AND pv.viewname = view_name;
END;
$function$
;

-- DROP FUNCTION public.util_grant_access(text, text, _text, _text, text);

CREATE OR REPLACE FUNCTION public.util_grant_access(pobjectname text, pobjecttype text, ppriviliges text[], proles text[], pschema text DEFAULT 'public'::text)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE
	lSupportedObjectTypes  TEXT[] = ARRAY['FUNCTION', 'TABLE', 'SEQUENCE', 'VIEW'];
	lGrantSql              TEXT = '';
	lTempRoles             TEXT[];
	lRole                  TEXT;
	lFunctionSql           TEXT = '';
	lProcCount             INTEGER = 0;
	lPgProc                RECORD;
BEGIN
	/*
		Grants access to a FUNCTION | TABLE | SEQUENCE | VIEW as specified in pObjectType

		Allowed priviliges in pPriviliges:
			FUNCTION     -> EXECUTE | ALL
			TABLE | VIEW -> SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER | ALL
			SEQUENCE      -> USAGE  | ALL
	*/

	-- Validate parameters
	pObjectType := UPPER( COALESCE( pObjectType, '' ) );

	IF ( NOT ( pObjectType = ANY( lSupportedObjectTypes ) ) ) THEN
		RAISE NOTICE 'Object type not supported: %. Must be one of: %', pObjectType, array_to_string( lSupportedObjectTypes, ', ' );
		RETURN 0;
	END IF;

	IF ( COALESCE( array_length( pPriviliges, 1 ), 0 ) = 0 OR COALESCE( array_length( pRoles, 1 ), 0 ) = 0 ) THEN
		RAISE NOTICE 'pPriviliges and pRoles arrays must be non-empty';
		RETURN 0;
	END IF;

	-- Add double quotes to role names
	lTempRoles := pRoles;
	pRoles = ARRAY[]::TEXT[];

	FOREACH lRole IN ARRAY lTempRoles LOOP
		pRoles := array_append( pRoles, quote_ident( lRole ) );
	END LOOP;

	-- Grant to every function with given name
	IF ( pObjectType = 'FUNCTION' ) THEN
		lFunctionSql := $$
			SELECT
				n.nspname,
				p.proname AS procname,
				pg_catalog.pg_get_function_identity_arguments( p.oid ) AS procargs
			FROM
				pg_proc p
				JOIN pg_namespace n ON p.pronamespace = n.oid
			WHERE
				p.proname = $1
				AND n.nspname = $2$$;

		FOR lPgProc IN EXECUTE( lFunctionSql ) USING pObjectName, pSchema LOOP
			lGrantSql := format('GRANT %s ON FUNCTION %I.%I( %s ) TO %s;', array_to_string( pPriviliges, ', ' ), lPgProc.nspname, lPgProc.procname, lPgProc.procargs, array_to_string( pRoles, ', ' ) );

			RAISE NOTICE '%', lGrantSql;
			EXECUTE lGrantSql;

			lProcCount := lProcCount + 1;
		END LOOP;

		IF ( lProcCount <= 0 ) THEN
			RAISE NOTICE 'No function(s) exist with name: %', pObjectName;
		END IF;

		RETURN lProcCount;

		-- Else grant for table/sequence
	ELSE
		lGrantSql := format('GRANT %s ON %I.%I TO %s;', array_to_string( pPriviliges, ', ' ), pSchema, pObjectName, array_to_string( pRoles, ', ' ) );

		RAISE NOTICE '%', lGrantSql;
		EXECUTE lGrantSql;

		RETURN 1;
	END IF;
END
$function$
;

-- DROP FUNCTION public.util_json_diff_objects(jsonb, jsonb);

CREATE OR REPLACE FUNCTION public.util_json_diff_objects(pleft jsonb, pright jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
DECLARE 
	r record;
BEGIN
	
	---------------------------------------------------------------------------------
	-- Return the logical difference of: pLeft - pRight. In other words, remove any
	-- key/value pairs from pLeft that are also contained in pRight
	---------------------------------------------------------------------------------

	IF ( pLeft IS NULL ) THEN 
		RETURN '{}'::jsonb;
	END IF;
	
	IF ( pRight IS NULL ) THEN 
		RETURN pLeft;
	END IF;
	
	-- Loop through each element of pRight and remove it if its contained in pLeft
	FOR r IN SELECT * FROM jsonb_each( pRight ) LOOP
        IF ( pLeft ? r.key AND pLeft->r.key = r.value ) THEN
            pLeft = pLeft - r.key;
        END IF;
    END LOOP;
	
	RETURN pLeft;
END;
$function$
;

-- DROP FUNCTION public.util_json_diff_objects_recursive(jsonb, jsonb);

CREATE OR REPLACE FUNCTION public.util_json_diff_objects_recursive(val1 jsonb, val2 jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
DECLARE
    result JSONB;
    object_result JSONB;
    i int;
    v RECORD;
BEGIN
    IF jsonb_typeof(val1) = 'null'
    THEN 
        RETURN val2;
    END IF;

    result = val1;
    FOR v IN SELECT * FROM jsonb_each(val1) LOOP
        result = result || jsonb_build_object(v.key, null);
    END LOOP;

    FOR v IN SELECT * FROM jsonb_each(val2) LOOP
        IF jsonb_typeof(val1->v.key) = 'object' AND jsonb_typeof(val2->v.key) = 'object'
        THEN
            object_result = util_json_diff_objects_recursive(val1->v.key, val2->v.key);
            -- check if result is not empty 
            i := (SELECT count(*) FROM jsonb_each(object_result));
            IF i = 0
            THEN 
                result = result - v.key; --if empty remove
            ELSE 
                result = result || jsonb_build_object(v.key,object_result);
            END IF;
        ELSIF val1->v.key = val2->v.key THEN 
            result = result - v.key;
        ELSE
            result = result || jsonb_build_object(v.key,v.value);
        END IF;
    END LOOP;

    RETURN result;

END;
$function$
;

-- DROP FUNCTION public.util_json_filter_paths(in jsonb, variadic _text);

CREATE OR REPLACE FUNCTION public.util_json_filter_paths(pjsonsource jsonb, VARIADIC ppaths text[])
 RETURNS jsonb
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
DECLARE
	lTextPath TEXT;
	lPath TEXT[];
	lPathKey TEXT;
	lKeyCount INT;
	lPrePath TEXT[];
	lSubRec RECORD;
	lSubObj JSONB;
	lSubMerged JSONB;
	lMerged JSONB = '{}'::JSONB;
	lFinal JSONB = '{}'::JSONB;
BEGIN
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Immutable function to exract each path from source (wildcards allowed) & return the merged subobjects
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- PARAMETERS :
	--   pJsonSource       : The input JSON object to extract values from
	--   pJsonObjects      : An variadic array of text paths to extract from the JSON
	-- RETURNS :
	--   JSONB             : Subobjects extracted by given paths and merged together
	-- EXAMPLES :
	--    SELECT util_json_filter_paths('{
	--      "k1": "v1", 
	--      "k2": {
	--        "kk1": {"x": {"a": "b"}, "y": 3, "z": 9}, 
	--        "kk2": {"x": 8, "y": 2, "z": 8}
	--      }, 
	--      "k3": {"f": "b", "g": "h"}}'::jsonb, 
	--      '{k1}', '{k3,f}', '{k2,*,x}', '{k2,*,y}');
	--   -- RETURNS: {"k1": "v1", "k2": {"kk1": {"x": {"a": "b"}, "y": 3}, "kk2": {"x": 8, "y": 2}}, "k3": {"f": "b"}}
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	-- * Validate input
	IF (pJsonSource IS NULL OR pPaths IS NULL) THEN
		RETURN NULL;
	END IF;

	--RAISE NOTICE '------------------------------------------';

	-- * Process each path given in variadic input param
	FOREACH lTextPath IN ARRAY pPaths LOOP
		--RAISE NOTICE '%', lTextPath;
		lPath = lTextPath::TEXT[];
		lMerged = '{}'::jsonb;
		lKeyCount = 0;
		lPrePath = '{}';
	
		-- * If we find any wildcards in the path, procees recursively
		IF (lPath @> '{*}') then
			-- * Loop through each path element
			FOREACH lPathKey IN ARRAY lPath LOOP
				IF (lPathKey != '*') then
					-- * Here we're incrementally building up the nested object
					lPrePath = lPrePath || lPathKey;
					lMerged = jsonb_set(lMerged, lPrePath, '{}'::jsonb);
					lKeyCount = lKeyCount + 1;
				ELSE
					-- * We get the object at path prior to wildcard, then loop over each found subobject 
					lSubObj = pJsonSource #> lPath[1:lKeyCount];
					FOR lSubRec IN
						SELECT * FROM jsonb_each(lSubObj) AS s(k, v)
					LOOP
						-- * Recursively call function to get the path following wildcard, within the subobject
						--RAISE NOTICE 'Each k:%, v:%', lSubRec.k, lSubRec.v;
						SELECT util_json_filter_paths(lSubRec.v, lPath[(lKeyCount+2):]::text) INTO lSubMerged;
						--RAISE NOTICE 'sm:%', lSubMerged;
						IF (lSubMerged != '{}'::jsonb) THEN
							lMerged = jsonb_set(lMerged, (lPrePath || lSubRec.k), lSubMerged);
						END IF;
						--RAISE NOTICE 'mg.1:%', lMerged;
					END LOOP;
					EXIT;
				END IF;
			END LOOP;
		else
				-- * Incrementally building up the nested object
				FOREACH lPathKey IN ARRAY lPath loop
					lPrePath = lPrePath || lPathKey;
					lMerged = jsonb_set(lMerged, lPrePath, '{}'::jsonb);
					lKeyCount = lKeyCount + 1;
				END LOOP;
				lMerged = jsonb_set(lMerged, lPath, pJsonSource #> lPath);
				--RAISE NOTICE 'mg.2:%', lMerged;
		END IF;
		
		lFinal = util_json_merge(lFinal, lMerged);
		--RAISE NOTICE 'final:%', lFinal;
		--RAISE NOTICE '-';
	END LOOP;

	RETURN lFinal;
END;
$function$
;

-- DROP FUNCTION public.util_json_merge(variadic _jsonb);

CREATE OR REPLACE FUNCTION public.util_json_merge(VARIADIC pjsonobjects jsonb[])
 RETURNS jsonb
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
DECLARE
	lObject JSONB;
	lMerged JSONB = '{}'::JSONB;
BEGIN
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Immutable recursive function to deep merge the contents of the multiple JSON input objects, left to right
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- PARAMETERS :
	--   pJsonObjects       : An array of JSONB input objects we want to merge
	-- RETURNS : 
	--   JSONB             : All input object data deep merged
	-- EXAMPLES :
	--    SELECT util_json_merge(
    --     '{"a":"foo","b":{"x":1,"y":2}}'::jsonb, 
	--     '{"b":{"x":"bar","z":3},"c":true}'::jsonb);
	--   -- RETURNS: {"a": "foo", "b": {"x": "bar", "y": 2, "z": 3}, "c": true}
	--
	--   SELECT	util_json_merge(
    --     '{"a":1,"z":true,"b":{"c":2,"d":3,"e":{"f":"x"}}}'::jsonb, 
	--     '{"b":{"c":8,"e":{"g":9}}}'::jsonb,
	--     '{"a":{"aa":"ff"}}'::jsonb ); 
	--   -- RETURNS: {"a": {"aa": "ff"}, "b": {"c": 8, "d": 3, "e": {"f": "x", "g": 9}}, "z": true}
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	-- * Validate input
	IF (pJsonObjects IS NULL) THEN
		RETURN NULL;
	END IF;
	
	-- * Deep merge objects
	FOREACH lObject IN ARRAY pJsonObjects LOOP
		SELECT 
			COALESCE(jsonb_object_agg(
				COALESCE(k1, k2), 
				CASE 
					WHEN v1 ISNULL THEN v2 
					WHEN v2 ISNULL THEN v1 
					WHEN jsonb_typeof(v1) <> 'object' OR jsonb_typeof(v2) <> 'object' THEN v2
					ELSE util_json_merge(v1, v2) 
				END 
			), '{}'::JSONB) 
			FROM jsonb_each(lMerged) e1(k1, v1) 
			FULL JOIN jsonb_each(lObject) e2(k2, v2) ON k1 = k2
		INTO
			lMerged;
	END LOOP;
	
	RETURN lMerged;
END;
$function$
;

-- DROP FUNCTION public.util_json_remove_keys(jsonb, _text);

CREATE OR REPLACE FUNCTION public.util_json_remove_keys(pjson jsonb, premovekeys text[])
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
BEGIN
	
	---------------------------------------------------------------------------------
	-- Return pJson object with all keys removed matching pRemoveKeys
	---------------------------------------------------------------------------------

	IF ( pJson IS NULL ) THEN 
		RETURN '{}'::jsonb;
	END IF;
	
	IF ( pRemoveKeys IS NULL OR array_length(pRemoveKeys, 1) IS NULL ) THEN 
		RETURN pJson;
	END IF;
	
	FOR i IN 1..array_length(pRemoveKeys, 1) LOOP
		pJson = pJson - pRemoveKeys[i];
	END LOOP;
	
	RETURN pJson;
END;
$function$
;

-- DROP FUNCTION public.util_normalize_locale(text, bool);

CREATE OR REPLACE FUNCTION public.util_normalize_locale(plocalecode text, pdefaultifinvalid boolean DEFAULT true)
 RETURNS text
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
DECLARE
	LOCALE_CODE_DEFAULT  TEXT = 'en_US';
	LOCALE_REGEX         TEXT = E'^([a-z]{2})(?:[_-]([a-z]{2})(?:[\\._-]machine)?)?$';
	lMatches             TEXT[];
BEGIN
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Immutable utility function to normalize an input locale string
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- PARAMETERS :
	--   pLocaleCode       : Locale code, e.g. en_GB, es_MX
	-- RETURNS : 
	--   TEXT              : Normalized locale code (Lang lowercase, region uppercase, delimited with an underscore)
	-- EXAMPLES :
	--   SELECT util_normalize_locale('es_MX');           -- RETURNS: es_MX
	--   SELECT util_normalize_locale('es_mx');           -- RETURNS: es_MX
	--   SELECT util_normalize_locale('es-mx');           -- RETURNS: es_MX
	--   SELECT util_normalize_locale('ES_mX');           -- RETURNS: es_MX
	--   SELECT util_normalize_locale('es_mx.machine');   -- RETURNS: es_MX
	--   SELECT util_normalize_locale('es_mx-machine');   -- RETURNS: es_MX
	--   SELECT util_normalize_locale('es_mx_machine');   -- RETURNS: es_MX
	--   SELECT util_normalize_locale('foobar');          -- RETURNS: en_US (default)
	--   SELECT util_normalize_locale('foobar', false);   -- RETURNS: NULL
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	-- * Validate input
	IF (COALESCE(pLocaleCode, '') = '' OR pLocaleCode !~* LOCALE_REGEX) THEN
		IF (pDefaultIfInvalid) THEN
			--RAISE NOTICE 'Parameter pLocaleCode is invalid, returning default: %', LOCALE_CODE_DEFAULT;
			RETURN LOCALE_CODE_DEFAULT;
		ELSE
			RETURN NULL;
		END IF;
	END IF;
	
	lMatches = regexp_match(pLocaleCode, LOCALE_REGEX, 'i');
	RETURN format($$%s_%s$$, LOWER(lMatches[1]), UPPER(lMatches[2]));	
END;
$function$
;

-- DROP FUNCTION public.util_percent_change(int4, int4, int4, bool, numeric);

CREATE OR REPLACE FUNCTION public.util_percent_change(pstart integer, pend integer, prounddigits integer DEFAULT NULL::integer, pnormalized boolean DEFAULT true, pifnull numeric DEFAULT 0)
 RETURNS numeric
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
BEGIN
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- Utility function to calculate percent change represented by pStart to pEnd value
	--  Integer arguments varation
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- "... See util_percent_change(NUMERIC, NUMERIC, ...) ..."
    -- EXAMPLES :
	-- 		with pc_tests as (
	-- 			select 1000.5::numeric as a, 500.5::numeric as b
	-- 			union all select 500.9, 1000.5
	-- 			union all select 500, null
	-- 		)
	-- 		select
	-- 			pg_typeof(a),
	-- 			a,b,
	-- 			util_percent_change(a,b) even,
	-- 			util_percent_change(a,b,null,false) uneven,
	-- 			util_percent_change(a,b,null,true,0) zero,
	-- 			util_percent_change(a,b,null,false,0) uneven_zero,
	--          util_percent_change(a,b,1,true,0) round1dig
	-- 		from
	-- 			pc_tests;
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	return util_percent_change(pStart::numeric, pEnd::numeric, pRoundDigits, pNormalized, pIfNull);
END;
$function$
;

-- DROP FUNCTION public.util_percent_change(numeric, numeric, int4, bool, numeric);

CREATE OR REPLACE FUNCTION public.util_percent_change(pstart numeric, pend numeric, prounddigits integer DEFAULT NULL::integer, pnormalized boolean DEFAULT true, pifnull numeric DEFAULT 0)
 RETURNS numeric
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
DECLARE
_retval numeric;
    _divisor numeric;
BEGIN
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- Utility function to calculate percent change represented by pStart to pEnd value
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- PARAMETERS :
    --   pStart       : Start Value
    --   pEnd         : Ending value
    --   pRoundDigits : Round to digits
    --   pNormalized  : Normalize / Even percent change
    --   pIfNull      : Return this value if result is null
    -- RETURNS :
    --   NUMERIC      : Percent change from start to end value
    -- EXAMPLES :
	-- 		with pc_tests as (
	-- 			select 1000 as a, 500 as b
	-- 			union all select 500, 1000
	-- 			union all select 500, null
	-- 		)
	-- 		select
	-- 			pg_typeof(a),
	-- 			a,b,
	-- 			util_percent_change(a,b) even,
	-- 			util_percent_change(a,b,null,false) uneven,
	-- 			util_percent_change(a,b,null,true,0) zero,
	-- 			util_percent_change(a,b,null,false,0) uneven_zero,
	-- 			util_percent_change(a,b,1,true,0) round1dig
	-- 		from
	-- 			pc_tests
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	_divisor = case when pNormalized then ((pStart+pEnd)::numeric/2) else pStart::numeric end;
	_retval = (pStart-pEnd)::numeric / nullif(_divisor, 0);
	return case when _retval is not null then
		case when pRoundDigits is not null then round(_retval, pRoundDigits) else _retval end
        else pIfNull end;
END;
$function$
;

-- DROP FUNCTION public.util_reorder_table(text, text, json, bool, bool);

CREATE OR REPLACE FUNCTION public.util_reorder_table(pschema text, ptable text, pcolumnorder json, pvalidateconstraints boolean DEFAULT true, pdryrun boolean DEFAULT false)
 RETURNS SETOF reorder_table_diagnostics
 LANGUAGE plpgsql
AS $function$
DECLARE

	ltime                TEXT = extract( EPOCH FROM clock_timestamp( ) ) :: INT :: TEXT;
	lDiagnosticTable     TEXT = 'reorder_table_diagnostics';
	lnewtablename        TEXT = 'reorder_' || ptable || '_' || ltime;
	lnewobjectnameprefix TEXT = 'reorder_' || ltime || '_';

	/*Sql statements*/
	lCreateTableSQL      TEXT = util_get_table_structure( pSchema, pTable, pColumnOrder, TRUE, TRUE, TRUE );
	lLockTableSQL        TEXT = 'LOCK TABLE %s.%s IN SHARE ROW EXCLUSIVE MODE';
	lDataMigrationSQL    TEXT = 'INSERT INTO %s.%s ( SELECT %s FROM %s.%s )';
	lDropTableSQL        TEXT = 'DROP TABLE %s.%s';
	lRenameTableSQL      TEXT = 'ALTER TABLE %s.%s RENAME TO %s';
	lReorderQueueSQL     TEXT = E'INSERT INTO staging.reorder_queue(deployment_id, query, created_on, updated_on) values (\'%s\', E\'%s\', \'%s\', \'%s\')';
	lSelfCallSQL         TEXT = E'SELECT public.util_reorder_table(\\\'%s\\\', \\\'%s\\\', \\\'%s\\\'::json)';

	/*@TODO: Handle table with multiple sequences*/
	lRenameSeqSQL        TEXT = 'ALTER TABLE %s.%s_id_seq RENAME TO %s_id_seq';
	lSetMaxSeqSQL        TEXT = E'SELECT setval(\'%s_id_seq\', (select last_value as id from %s.%s_id_seq), true)';

	lDiagnosticLogSQL    TEXT = E'INSERT INTO %s (log_type, reorder_table_name, query, start_time, end_time, error_message, exception_detail) VALUES ( \'%s\', \'%s\', %s, \'%s\', \'%s\', \'%s\', \'%s\' )';

	lDefaultViewPermissionSQL   text  = E'GRANT SELECT, UPDATE ON %s.%s_id_seq TO "postgres", "Administrators", "Developers", "PropertyManagers", "Prospects", "Residents";';

	lTempSQL             TEXT;
	ltempRecord          RECORD;
	lHasSeq              BOOLEAN := FALSE;

	lFkeyErrorMessage    TEXT;
	lFkeyErrorDetail     TEXT;

	lDryRunLogSuffix     TEXT = CASE WHEN pDryRun THEN ' - DRY RUN'
	                            ELSE '' END;

	lQueryStartTime      TIMESTAMP;
	lScriptStartTime     TIMESTAMP;
BEGIN

	lScriptStartTime = clock_timestamp( );

	/*Increase deadlock_timeout to 100 seconds*/
	SET deadlock_timeout = '100000';

	/*All queries to be fired*/
	DROP TABLE IF EXISTS pg_temp.execute_sqls;
	CREATE TEMP TABLE execute_sqls (
		query_type TEXT,
		query_text TEXT,
		id         SERIAL
	);


	/*Get dependency tree*/
	DROP TABLE IF EXISTS pg_temp.object_dependency;
	CREATE TEMP TABLE object_dependency AS (
		SELECT
			object_type,
			object_identity,
			trim( SUBSTRING( object_identity, E'(\\w+?)\\.' ) ) AS obj_schema,
			CASE object_type
			WHEN 'INDEX'
				THEN ptable
			ELSE trim( SUBSTRING( object_identity, E'\\w+\\.(\\w+)' ) )
			END AS target_table,
			CASE object_type
			WHEN 'INDEX'
				THEN trim( regexp_replace( object_identity, E'\\w+\.', '' ) )
			WHEN 'RULE'
				THEN substring( object_identity, E'\\.(\\w+)' )
			ELSE trim( regexp_replace( object_identity, E'on (.+)?\\.(.+)', '' ) )
			END AS obj_name
		FROM
				util_dependency_tree( ARRAY [ptable] :: TEXT [] )
		WHERE
			object_type NOT IN ( 'SCHEMA', 'TABLE', 'SEQUENCE', 'DEFAULT VALUE' ) );

	/*dynamic ddl sqls*/
	DROP TABLE IF EXISTS pg_temp.dml_sqls;
	CREATE TEMP TABLE dml_sqls AS (
		SELECT
			*,
			CASE
			WHEN object_type = 'TABLE CONSTRAINT'
				THEN substring( add_sql, E'(.+) ADD CONSTRAINT' ) || ' DROP CONSTRAINT %2s'
			WHEN object_type = 'RULE' THEN 'DROP VIEW ' || target_schema || '.' || '%1s'
			ELSE NULL
			END AS drop_sql,
			CASE
			WHEN object_type = 'TABLE CONSTRAINT'
				THEN substring( add_sql, E'(.+) ADD CONSTRAINT' ) || ' RENAME CONSTRAINT %2s TO %3s'
			WHEN object_type = 'INDEX'
				THEN 'ALTER INDEX %1s RENAME TO %2s'
			ELSE NULL
			END AS rename_sql,
			CASE
			WHEN add_sql ILIKE '%primary key%'
				THEN 1
			WHEN add_sql ILIKE '%index%'
				THEN 2
			WHEN object_type = 'INDEX'
				THEN 3
			WHEN object_type = 'TABLE CONSTRAINT' AND target_table = ptable
				THEN 4
			WHEN object_type = 'TABLE CONSTRAINT'
				THEN 5
			ELSE
				6
			END AS order_num
		FROM
			(
				SELECT
					obj_schema AS target_schema,
					object_type,
					target_table,
					obj_name AS object_name,
					CASE
					WHEN object_type = 'TABLE CONSTRAINT'
						THEN util_get_constraint_def( obj_schema, target_table, obj_name, TRUE, pTable )
					WHEN object_type = 'INDEX'
						THEN util_get_index_def( obj_schema, target_table, obj_name, TRUE )
					WHEN object_type = 'TRIGGER'
						THEN util_get_trigger_def( obj_schema, target_table, obj_name, TRUE )
					WHEN object_type = 'RULE'
						THEN util_get_view_def( obj_schema, obj_name, TRUE )
					ELSE '--NA'
					END AS add_sql
				FROM
					object_dependency ) sub_query );

	--New table
	ltempsql := format( lCreateTableSQL, lnewtablename );
	INSERT INTO execute_sqls
	VALUES
		( 'NEW TABLE CREATION', ltempsql );

	IF(EXISTS (select regexp_matches(ltempsql, 'id serial','i'))) THEN
		lHasSeq := true;
	END IF;

	--Lock table
	INSERT INTO execute_sqls
	VALUES
		( 'LOCK OLD TABLE', format( lLockTableSQL, pSchema, pTable ) );

	--Data migration from old to new
	----Derive ordered columns
	SELECT
		array_to_string( array_agg( column_name
		                 ORDER BY
			                 column_order ), ', ' )
	FROM
		pg_temp.column_order_json
	INTO ltempsql;

	INSERT INTO execute_sqls
	VALUES
		( 'MIGRATE DATA FROM OLD TABLE', format( lDataMigrationSQL, pSchema, lnewtablename, ltempsql, pSchema, pTable ) );

	--Add constraint, indexes & triggers
	FOR ltempRecord IN SELECT
		                   *
	                   FROM
		                   dml_sqls
	                   WHERE
		                   object_type != 'RULE'
	                   ORDER BY
		                   order_num
	LOOP

		IF ( ltempRecord.object_type = 'TABLE CONSTRAINT' ) THEN
			IF ( ltempRecord.target_table != pTable ) THEN
				lTempSql = format( ltempRecord.add_sql, ltempRecord.target_table, lnewobjectnameprefix || ltempRecord.object_name, lnewtablename );
			ELSE
				lTempSql = format( ltempRecord.add_sql, lnewtablename, lnewobjectnameprefix || ltempRecord.object_name, lnewtablename );
			END IF;
		ELSEIF ( ltempRecord.object_type = 'INDEX' ) THEN
			lTempSql = format( ltempRecord.add_sql, lnewobjectnameprefix || ltempRecord.object_name, lnewtablename );
		ELSE
			lTempSql = format( ltempRecord.add_sql, ltempRecord.object_name, lnewtablename );
		END IF;

		INSERT INTO execute_sqls
		VALUES
			( 'ADD CONSTRAINTS, TRIGGERS & INDEXES', regexp_replace( lTempSql, E'(REFERENCES.+)(NOT VALID)?$', E'\\1 NOT VALID' ) );
	END LOOP;

	---validate constraints
	INSERT INTO execute_sqls
		(
			SELECT
				query_type,
				substring( replace( query_text, 'ADD', 'VALIDATE' ), '(.+)FOREIGN KEY' )
			FROM
				execute_sqls
			WHERE
				query_text ILIKE '%REFERENCES%'
				AND query_type = 'ADD CONSTRAINTS, TRIGGERS & INDEXES'
				AND pValidateConstraints );

	--Drop dependant constraints on target table
	FOR ltempRecord IN SELECT
		                   *
	                   FROM
		                   dml_sqls
	                   WHERE
		                   object_type IN ( 'RULE', 'TABLE CONSTRAINT' )
		                   AND ( object_type = 'RULE' OR target_table != ptable )
	                   ORDER BY
		                   order_num
	LOOP
		IF ( ltempRecord.object_type = 'RULE' ) THEN
			lTempSql = FORMAT( ltempRecord.drop_sql, ltempRecord.object_name );
		ELSE
			lTempSql = FORMAT( ltempRecord.drop_sql, ltempRecord.target_table, ltempRecord.object_name );
		END IF;

		INSERT INTO execute_sqls
		VALUES
			( 'DROP DEPENDANT CONSTRAINTS', lTempSql );
	END LOOP;

	--Set seq permission
	IF(lHasSeq) THEN
		INSERT INTO execute_sqls
		VALUES
		 ( 'SET SEQUENCE', Format( lSetMaxSeqSQL, lnewtablename, pSchema, pTable ) );
	end if;

	--DROP old table
	INSERT INTO execute_sqls
	VALUES
		( 'DROP OLD TABLE', format( lDropTableSQL, pSchema, pTable ) );

	--Rename constraints, indexs & triggers
	FOR ltempRecord IN SELECT
		                   *
	                   FROM
		                   dml_sqls
	                   WHERE
		                   object_type != 'RULE'
		                   AND rename_sql IS NOT NULL
	                   ORDER BY
		                   order_num
	LOOP
		IF ( ltempRecord.object_type = 'INDEX' ) THEN
			lTempSql = format( ltempRecord.rename_sql, lnewobjectnameprefix || ltempRecord.object_name, ltempRecord.object_name );
		ELSEIF ( ltempRecord.target_table != pTable ) THEN
			lTempSql = format( ltempRecord.rename_sql, ltempRecord.target_table, lnewobjectnameprefix || ltempRecord.object_name, ltempRecord.object_name );
		ELSE
			lTempSql = format( ltempRecord.rename_sql, lnewtablename, lnewobjectnameprefix || ltempRecord.object_name, ltempRecord.object_name );
		END IF;

		INSERT INTO execute_sqls
		VALUES
			( 'RENAME CONSTRAINTS & INDEXES', lTempSql );
	END LOOP;

	--Rename new table & sequence
	INSERT INTO execute_sqls
	VALUES
		( 'RENAME NEW TABLE TO ORIGINAL NAME', Format( lRenameTableSQL, pSchema, lnewtablename, pTable ) );

	--rename & add permissions for seq
	IF(lHasSeq) THEN
		INSERT INTO execute_sqls
		VALUES
		 ( 'RENAME SEQUENCE', Format( lRenameSeqSQL, pSchema, lnewtablename, pTable ) ),
		 ( 'RESTORE SEQUENCE PERMISSIONS', Format( lDefaultViewPermissionSQL, pSchema, pTable ) );
	end if;

	--Finally add views
	FOR ltempRecord IN SELECT
		                   *
	                   FROM
		                   dml_sqls
	                   WHERE
		                   object_type = 'RULE'
	                   ORDER BY
		                   order_num
	LOOP
		lTempSql = format( ltempRecord.add_sql, ltempRecord.object_name );
		INSERT INTO execute_sqls
		VALUES
			( 'ADD VIEWS', lTempSql ),
			( 'ADD VIEW PERMISSIONS', ( SELECT
				                            array_to_string( array_agg( permission_sql ), E';\n' )
			                            FROM
				                            (
					                            SELECT
						                            'GRANT ' || array_to_string( array_agg( privilege_type :: TEXT ), ', ' ) || ' ON ' || ltempRecord.target_schema || format('.%1$s TO ', ltempRecord.object_name ) || '"' || grantee || '"' AS permission_sql
					                            FROM
						                            information_schema.role_table_grants
					                            WHERE
						                            table_name = ltempRecord.object_name
						                            AND table_schema = pSchema
					                            GROUP BY
						                            grantee,
						                            pTable,
						                            table_schema ) AS sub_query ));
	END LOOP;

	--Formatting queries
	UPDATE execute_sqls es
	SET
		query_text = sub_query.output_query
	FROM
		(
			SELECT
				id,
				CASE
				WHEN row_number = 1
					THEN E'\n\n/*' || query_type || E'*/ \n\n'
				ELSE ''
				END || query_text AS output_query
			FROM
				(
					SELECT
						*,
						row_number( )
						OVER (
							PARTITION BY query_type
							ORDER BY
								id )
					FROM
						execute_sqls rs ) sub_query ) sub_query
	WHERE
		sub_query.id = es.id;


	--for development env we reorder tables at night
	BEGIN
		--Throws an exception when not defined
		perform current_setting('env.branch.trunk');
		EXECUTE ( format( lReorderQueueSQL, current_setting( 'env.deployment_id' ), format( lSelfCallSQL, pschema, ptable, pcolumnorder ), now( ), now( ) ) );
		raise notice 'Skipping run on local';
		return;

		EXCEPTION WHEN others THEN
		--continue below..
	END;

	--Execute queries
	FOR ltempRecord IN SELECT
		                   query_text
	                   FROM
		                   execute_sqls
	                   ORDER BY
		                   id
	LOOP

		BEGIN
			lQueryStartTime = clock_timestamp( );

			IF ( FALSE = pDryRun ) THEN
				RAISE INFO 'Query: %', ltempRecord.query_text;
				EXECUTE ltempRecord.query_text;
			END IF;

			EXECUTE ( format( lDiagnosticLogSQL, lDiagnosticTable, 'LOG' || lDryRunLogSuffix, lnewtablename, quote_literal( ltempRecord.query_text ), lQueryStartTime, clock_timestamp( ), NULL, NULL ) );

			EXCEPTION WHEN foreign_key_violation THEN

			--Log error
			GET STACKED DIAGNOSTICS lFkeyErrorMessage = MESSAGE_TEXT, lFkeyErrorDetail = PG_EXCEPTION_DETAIL;
			EXECUTE ( format( lDiagnosticLogSQL, lDiagnosticTable, 'ERROR', lnewtablename, quote_literal( ltempRecord.query_text ), lQueryStartTime, clock_timestamp( ), lFkeyErrorMessage, lFkeyErrorDetail ) );

		END;
	END LOOP;

	EXECUTE format( lDiagnosticLogSQL, lDiagnosticTable, 'SUCCESS' || lDryRunLogSuffix, lnewtablename, quote_literal( '******* REORDERED TABLE ' || pTable || '********' ), lScriptStartTime, clock_timestamp( ), NULL, NULL );

	RETURN QUERY SELECT
		             *
	             FROM
		             reorder_table_diagnostics
	             WHERE
		             reorder_table_name = lnewtablename
	             ORDER BY
		             NULLIF( log_type, 'SUCCESS' ) NULLS FIRST,
		             log_type,
		             id;

END;

$function$
;

-- DROP FUNCTION public.util_set_locale(text, text, text, bool);

CREATE OR REPLACE FUNCTION public.util_set_locale(plocalecode text, pdefaultlocalecode text, ptargetlocalecode text DEFAULT NULL::text, pacceptmachinetranslated boolean DEFAULT false)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
	lAliasLocaleCode TEXT = NULL;
BEGIN
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Utility function to set the locale for the session
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- PARAMETERS :
	--   pLocaleCode              : Locale code, e.g. en_GB, es_MX
	--   pDefaultLocaleCode       : Default locale code for company/entity
	--   pTargetLocaleCode        : [OPTIONAL] Target locale code (if updating/inserting data for a locale different than pLocaleCode)
	--   pAcceptMachineTranslated : [OPTIONAL] Indicates if we should recognize machine translated values e.g. en_GB.machine
	-- EXAMPLES :
	--   SELECT util_set_locale( 'es_MX', 'en_US' );
	--   SELECT util_set_locale( 'es_MX', 'en_US', 'zh_CN', TRUE );
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	-- * Normalize input
	SELECT public.util_normalize_locale(pLocaleCode) INTO pLocaleCode;
	SELECT public.util_normalize_locale(pDefaultLocaleCode) INTO pDefaultLocaleCode;
	SELECT public.util_normalize_locale(pTargetLocaleCode, FALSE) INTO pTargetLocaleCode;


	--- * Check if requested locale is an alias locale
	lAliasLocaleCode = CASE
		WHEN pLocaleCode = 'de_AT' THEN 'de_DE'
		WHEN pLocaleCode = 'en_IE' THEN 'en_GB'
		WHEN pLocaleCode = 'en_CA' THEN 'en_US'
		WHEN pLocaleCode = 'es_US' THEN 'es_MX'
		WHEN pLocaleCode = 'fr_CA' THEN 'fr_FR'
	END;

	-- Set values into Entrata namespaced GUC session variables
	PERFORM set_config('ent.locale_code', pLocaleCode, false);
	PERFORM set_config('ent.default_locale_code', pDefaultLocaleCode, false);
	PERFORM set_config('ent.target_locale_code', pTargetLocaleCode, false);
	PERFORM set_config('ent.alias_locale_code', lAliasLocaleCode, false);
	PERFORM set_config('ent.accept_machine_translated', pAcceptMachineTranslated::TEXT, false);
END;
$function$
;

-- DROP FUNCTION public.util_set_row_translated(regclass, jsonb, int4, text);

CREATE OR REPLACE FUNCTION public.util_set_row_translated(ptableregclass regclass, ptablerow jsonb, pcompanyuserid integer, plocalecode text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
DECLARE
	TRANSLATED_DETAILS_KEY        TEXT = '_translated';
	TRANSLATED_COLUMN_ANNOTATION  TEXT = '@translated@';
	TRANSLATED_COLUMN_NEW_ANNOTATION  TEXT = '"translated":true';
	ANNOTATED_REGEX               TEXT = format( E'(.*%s.*|.*%s.*)', TRANSLATED_COLUMN_ANNOTATION, TRANSLATED_COLUMN_NEW_ANNOTATION );
	lStatementStartTime           TIMESTAMP;
	lAttributeRec                 RECORD;
	lAttributePath                TEXT[];
	lDetails                      JSONB = '{}'::JSONB;
	lPkeyCols                     TEXT[] = '{}'::TEXT[];
	lPkeyVals                     INT[]  = '{}'::INT[];
	lSqlUpdate                    TEXT;
	lDefaultLocaleCode            TEXT;
BEGIN
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Utility function to persist translations for a single local for the given record into its details
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- PARAMETERS :
	--   pTableRegclass   : Regclass of target table
	--   pTableRow        : JSONB representing 1 row of data from table
	--   pCompanyUserId   : UserId performing update
	--   pLocaleCode      : [OPTIONAL] Override locale code from current_setting
	-- RETURNS :
	--   JSONB            : Updated value of _translated details node
	-- EXAMPLES :
	/*
	   ASSUMPTIONS
	   ~ Table public.announcements exists
	   ~ Table exists with two @translated@ annotated columns: title and announcement

	   -- Example 1: Standard sql usage; setting a single value (title) into translated es_MX details
	   SELECT util_set_locale('es_MX', 'en_US');  -- initalize locale for session
	   SELECT util_set_row_translated('announcements'::regclass, '{"id":32887, "cid":13263, "title":"La piscina cierra a las 9pm"}', 289) FROM announcements AS a WHERE (id,cid) = (32287,13263);

	   -- Example 2: Standard sql usage; setting multiple values (title, announcement) into translated es_MX details, explicitly overriding locale via parameter
	   SELECT util_set_row_translated('announcements'::regclass, '{"id":32887, "cid":13263, "title":"La piscina cierra a las 9pm", "announcement":"Hora de cierre"}', 289, 'ex_MX') FROM announcements AS a WHERE (id,cid) = (32287,13263);

	   -- Example 3: Usage within another inserting plpgsql function; This copies discreet column values to translated es_MX details
	   SELECT util_set_locale('es_MX', 'en_US');  -- initalize locale for session (this can be done inside or outside of target function)
	   ...within target function...
	   DECLARE lInsertedRecord RECORD;
	   ...
	   INSERT INTO public.announcements ( ...columns... ) VALUES ( ...values... ) RETURNING * INTO lInsertedRecord;
	   PERFORM util_set_row_translated('announcements'::regclass, to_jsonb(lInsertedRecord), 289);

	   -- Example 4: Standard sql usage; directly copying a record's discreet column values to translated es_MX details
	   SELECT util_set_locale('es_MX', 'en_US');  -- initalize locale for session
	   SELECT util_set_row_translated('announcements'::regclass, to_jsonb(a.*), 289) FROM announcements AS a WHERE (id,cid) = (32287,13263);
	*/
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	lStatementStartTime = clock_timestamp();

	-- * Validate & Initialize
	IF (COALESCE(pTableRegclass::TEXT, '') = '') THEN
		RAISE EXCEPTION 'Parameter pTableRegclass is invalid table regclass';
	ELSIF (COALESCE(btrim(pTableRow::TEXT, '{}'), '') = '') THEN
		RAISE EXCEPTION 'Parameter pTableRow contains an invalid/empty JSON value';
	END IF;

	-- * In order of precedence, coalesce to select locale: param-locale, setting-target (if not ignored), setting-locale, default-locale
	SELECT COALESCE(
			public.util_normalize_locale(pLocaleCode, FALSE),
			public.util_normalize_locale(current_setting('ent.target_locale_code', TRUE), FALSE),
			public.util_normalize_locale(current_setting('ent.locale_code', TRUE), FALSE),
			public.util_normalize_locale(current_setting('ent.default_locale_code', TRUE))
	) INTO pLocaleCode;

	-- * Merge current details with input values for @translated@ columns into the translated node for selected locale
	SELECT
		util_json_merge(
			(pTableRow->>'details')::jsonb,
			format($${%s: {%s: %s}}$$,
				to_json(TRANSLATED_DETAILS_KEY),
				to_json(pLocaleCode),
				jsonb_object_agg(c.attname, pTableRow->>c.attname))::jsonb
		)
	INTO
		lDetails
	FROM
		pg_attribute AS c
	WHERE
		c.attrelid = pTableRegclass::regclass
		AND c.attnum > 0
		AND NOT c.attisdropped
		AND col_description(c.attrelid, c.attnum) ~* ANNOTATED_REGEX;
	--RAISE NOTICE 'lDetails: %', lDetails;

	-- * Derive an array of the primary key cols and values
	SELECT
		array_agg(c.attname::TEXT),
		array_agg((pTableRow->>c.attname)::INT) FILTER (WHERE COALESCE((pTableRow->>c.attname), '') <> '')
	INTO
		lPkeyCols,
		lPkeyVals
	FROM
		pg_index AS i
		JOIN pg_class AS t ON i.indrelid = t.oid
		JOIN pg_attribute AS c ON
			c.attrelid = i.indrelid
			AND c.attnum = ANY(i.indkey)
	WHERE
		t.oid = pTableRegclass::regclass
		AND i.indisprimary;
	--RAISE NOTICE 'pkc: %, pkv: %', lPkeyCols, lPkeyVals;

	IF (COALESCE(array_length(lPkeyCols, 1), 0) <> COALESCE(array_length(lPkeyVals, 1), 0)) THEN
		RAISE EXCEPTION 'Error input pTableRow must provide values for all pkey columns: (%)', array_to_string(lPkeyCols, ',');
	END IF;

	-- * Update the table record
	lSqlUpdate = format($$UPDATE %s SET updated_on = NOW(), updated_by = %s, details = %L::JSONB WHERE (%s) = (%s)$$,
		pTableRegclass,
		pCompanyUserId,
		lDetails,
		array_to_string(lPkeyCols, ','),
		array_to_string(lPkeyVals, ','));
	--RAISE NOTICE 'Time: %, lSqlUpdate: %', (clock_timestamp() - lStatementStartTime), lSqlUpdate;

	EXECUTE lSqlUpdate;
	RETURN lDetails->TRANSLATED_DETAILS_KEY;
END;
$function$
;

-- DROP FUNCTION public.uuid_generate_v1();

CREATE OR REPLACE FUNCTION public.uuid_generate_v1()
 RETURNS uuid
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_generate_v1$function$
;

-- DROP FUNCTION public.uuid_generate_v1mc();

CREATE OR REPLACE FUNCTION public.uuid_generate_v1mc()
 RETURNS uuid
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_generate_v1mc$function$
;

-- DROP FUNCTION public.uuid_generate_v3(uuid, text);

CREATE OR REPLACE FUNCTION public.uuid_generate_v3(namespace uuid, name text)
 RETURNS uuid
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_generate_v3$function$
;

-- DROP FUNCTION public.uuid_generate_v4();

CREATE OR REPLACE FUNCTION public.uuid_generate_v4()
 RETURNS uuid
 LANGUAGE c
 PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_generate_v4$function$
;

-- DROP FUNCTION public.uuid_generate_v5(uuid, text);

CREATE OR REPLACE FUNCTION public.uuid_generate_v5(namespace uuid, name text)
 RETURNS uuid
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_generate_v5$function$
;

-- DROP FUNCTION public.uuid_nil();

CREATE OR REPLACE FUNCTION public.uuid_nil()
 RETURNS uuid
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_nil$function$
;

-- DROP FUNCTION public.uuid_ns_dns();

CREATE OR REPLACE FUNCTION public.uuid_ns_dns()
 RETURNS uuid
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_ns_dns$function$
;

-- DROP FUNCTION public.uuid_ns_oid();

CREATE OR REPLACE FUNCTION public.uuid_ns_oid()
 RETURNS uuid
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_ns_oid$function$
;

-- DROP FUNCTION public.uuid_ns_url();

CREATE OR REPLACE FUNCTION public.uuid_ns_url()
 RETURNS uuid
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_ns_url$function$
;

-- DROP FUNCTION public.uuid_ns_x500();

CREATE OR REPLACE FUNCTION public.uuid_ns_x500()
 RETURNS uuid
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/uuid-ossp', $function$uuid_ns_x500$function$
;

-- DROP FUNCTION public.word_similarity(text, text);

CREATE OR REPLACE FUNCTION public.word_similarity(text, text)
 RETURNS real
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$word_similarity$function$
;

-- DROP FUNCTION public.word_similarity_commutator_op(text, text);

CREATE OR REPLACE FUNCTION public.word_similarity_commutator_op(text, text)
 RETURNS boolean
 LANGUAGE c
 STABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$word_similarity_commutator_op$function$
;

-- DROP FUNCTION public.word_similarity_dist_commutator_op(text, text);

CREATE OR REPLACE FUNCTION public.word_similarity_dist_commutator_op(text, text)
 RETURNS real
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$word_similarity_dist_commutator_op$function$
;

-- DROP FUNCTION public.word_similarity_dist_op(text, text);

CREATE OR REPLACE FUNCTION public.word_similarity_dist_op(text, text)
 RETURNS real
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$word_similarity_dist_op$function$
;

-- DROP FUNCTION public.word_similarity_op(text, text);

CREATE OR REPLACE FUNCTION public.word_similarity_op(text, text)
 RETURNS boolean
 LANGUAGE c
 STABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$word_similarity_op$function$
;