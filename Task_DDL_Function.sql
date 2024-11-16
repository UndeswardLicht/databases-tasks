-- 1.Create a view called "sales_revenue_by_category_qtr" that shows the film category
-- and total sales revenue for the current quarter.
-- The view should only display categories with at least one sale in the current quarter.
-- The current quarter should be determined dynamically.

create or replace view sales_revenue_by_category_qtr as
select qua.name, qua.quarter, sum(amount) as total_revenue
from
	(select ca.name, re.rental_id, pa.payment_id, pa.amount, extract(quarter from pa.payment_date) quarter
	from rental re
	join payment pa
	on re.rental_id = pa.rental_id
	join inventory inv
	on re.inventory_id = inv.inventory_id
	join film
	on inv.film_id = film.film_id
	join film_category fc
	on film.film_id = fc.film_id
	join category ca
	on fc.category_id = ca.category_id) qua
group by qua.name, qua.quarter
having quarter = (select extract(quarter from current_date))
		
-- 2. Create a query language function called "get_sales_revenue_by_category_qtr" that accepts one parameter
-- representing the current quarter and returns the same result as the "sales_revenue_by_category_qtr" view.

CREATE OR REPLACE FUNCTION GET_SALES_REVENUE_BY_CATEGORY_QTR(IN QUARTER_NUMBER int)
RETURNS TABLE (NAME text, QUARTER int, TOTAL_REVENUE numeric)
AS $$
SELECT QUA.NAME,
	QUA.QUARTER,
	SUM(AMOUNT) AS TOTAL_REVENUE
FROM
	(SELECT CA.NAME,
			RE.RENTAL_ID,
			PA.PAYMENT_ID,
			PA.AMOUNT,
			EXTRACT(QUARTER FROM PA.PAYMENT_DATE) QUARTER
		FROM RENTAL RE
		JOIN PAYMENT PA ON RE.RENTAL_ID = PA.RENTAL_ID
		JOIN INVENTORY INV ON RE.INVENTORY_ID = INV.INVENTORY_ID
		JOIN FILM ON INV.FILM_ID = FILM.FILM_ID
		JOIN FILM_CATEGORY FC ON FILM.FILM_ID = FC.FILM_ID
		JOIN CATEGORY CA ON FC.CATEGORY_ID = CA.CATEGORY_ID) QUA
GROUP BY QUA.NAME,
	QUA.QUARTER
HAVING QUARTER = QUARTER_NUMBER
$$
LANGUAGE SQL;

-- 3. Create a procedure language function called "new_movie" that takes a movie title as a parameter
-- and inserts a new movie with the given title in the film table.
-- The function should generate a new unique film ID, set the rental rate to 4.99,
-- the rental duration to three days, the replacement cost to 19.99,
-- the release year to the current year, and "language" as Klingon.
-- The function should also verify that the language exists in the "language" table.
-- Then, ensure that no such function has been created before; if so, replace it.

CREATE OR REPLACE FUNCTION NEW_MOVIE (IN I_FILM_TITLE text) RETURNS bigint LANGUAGE PLPGSQL AS $$
declare
	id_of_added_film int;
	release_year int := extract(year from current_date);
	film_language_id int;
	film_language text :=  'Klingon';
	rental_duration int := 3;
	rental_rate numeric(4,2) := 4.99;
	replacement_cost numeric(5,2) := 19.99;

begin
		BEGIN
			IF EXISTS (SELECT LANGUAGE_ID
			FROM LANGUAGE
			WHERE NAME = 'Klingon') THEN FILM_LANGUAGE_ID = LANGUAGE_ID;
			ELSE
			FILM_LANGUAGE_ID = 1;
			RAISE NOTICE 'Language % not found, film language will be set to English', FILM_LANGUAGE;
			END IF;
		END;
	insert into film (title, release_year, language_id, rental_duration, rental_rate, replacement_cost)
	values (i_film_title, release_year, film_language_id, rental_duration, rental_rate, replacement_cost)
	returning film_id into id_of_added_film;

	raise notice 'New film % is added!. ID = %', i_film_title, id_of_added_film;

	return id_of_added_film;
end;
$$;




	
	
	