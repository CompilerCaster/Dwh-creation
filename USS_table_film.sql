DROP TABLE IF EXISTS staging.film;
CREATE TABLE staging.film (
    film_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NULL,
    release_year INT2 NULL,
    language_id INT2 NOT NULL,
    rental_duration INT2 NOT NULL,
    rental_rate NUMERIC(4, 2) NOT NULL,
    length INT2 NULL,
    replacement_cost NUMERIC(5, 2) NOT NULL,
    rating VARCHAR(10) NULL,
    last_update TIMESTAMP NOT NULL,
    special_features _TEXT NULL,
    fulltext TSVECTOR NOT NULL
);

select * from staging.film

select * from pg_available_extensions;

create extension postgres_fdw;

create server film_pg foreign data wrapper postgres_fdw options (
	host 'localhost',
	dbname 'postgres',
	port '5432'
);

create user mapping for postgres server film_pg options (
	user 'postgres',
	password 'admin'
);

drop schema if exists film_src;
create schema film_src authorization postgres;

drop type if exists mpaa_rating;
CREATE TYPE public.mpaa_rating AS ENUM (
	'G',
	'PG',
	'PG-13',
	'R',
	'NC-17');

drop type if exists year;
CREATE DOMAIN public.year AS integer
	CONSTRAINT year_check CHECK (VALUE >= 1901 AND VALUE <= 2155);

import foreign schema public from server film_pg into film_src;

drop procedure if exists staging.file_load():
create or replace  procedure staging.film_load()
as $$
	begin
		truncate table staging.film;
		insert
		into
		staging.film
			(film_id,
			title,
			description,
			release_year,
			language_id,
			rental_duration,
			rental_rate,
			length,
			replacement_cost,
			rating,
			last_update,
			special_features,
			fulltext)
		select
			film_id,
			title,
			description,
			release_year,
			language_id,
			rental_duration,
			rental_rate,
			length,
			replacement_cost,
			rating,
			last_update,
			special_features,
			fulltext
		from
			film_src.film;

	end;
$$ language plpgsql;

call staging.film_load();

select * from staging.film;


	


