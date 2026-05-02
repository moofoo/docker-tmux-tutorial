-- PG_DUMP BOILERPLATE ---------------------------------
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

-- CREATE DATABASE ---------------------------------
DROP DATABASE IF EXISTS tutorial_db;

CREATE DATABASE tutorial_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'C.UTF-8';

ALTER DATABASE tutorial_db OWNER TO postgres;

\connect tutorial_db

--  TABLES ---------------------------------
create table if not exists public.users
(
    id bigserial primary key,
    first_name varchar,
    last_name varchar,
    email varchar
);
