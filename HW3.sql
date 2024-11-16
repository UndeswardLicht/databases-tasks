--1. Write a query that will return for each year the most popular in rental film among films released in one year.

with film_from_inventory
as (select f.film_id, i.inventory_id, f.title, f.release_year 
	from film f
	join inventory i
   on f.film_id = i.film_id),
grouped_by_title
as (
	select /* r.inventory_id, ffi.film_id,*/ ffi.title, ffi.release_year, count(r.rental_id) as how_often_rented
	from rental r
	join film_from_inventory ffi
	on ffi.inventory_id = r.inventory_id
	group by ffi.title, ffi.release_year
	order by ffi.release_year, how_often_rented
	)
--Since there are sometimes two films with the same number of rentals in one year,
--I've left them in the column
select title, release_year, how_often_rented
from (select title, release_year, how_often_rented,
		rank() over (partition by release_year order by how_often_rented desc) rnk
		from grouped_by_title) gr
where gr.rnk=1

--2. Write a query that will return the Top-5 actors who have appeared in Comedies more than anyone else.

select actor_id, count(actor_id) as number_of_appearings from film_actor
where film_id in (select film_id from film_category
				  where category_id = (select category_id from category
									   where category.name = 'Comedy')
				  )
group by actor_id
order by number_of_appearings desc
limit 5

--3. Write a query that will return the names of actors who have not starred in “Action” films.

with action_films
as (select film_id as film_id_fc from film_category
	where category_id = (select category_id from category 
						 where category.name = 'Action')
	)
	
select actor.actor_id, first_name || ' ' || last_name as full_name
from actor 
left outer join (select distinct(actor_id)
					from film_actor fa
					left outer join action_films af
					on fa.film_id = af.film_id_fc
					where af.film_id_fc is not null
				  ) action_actor
on actor.actor_id = action_actor.actor_id
where action_actor.actor_id is null

--4. Write a query that will return the three most popular in rental films by each genre.

with
rented_films 
as (select r.rental_id, i.film_id, f.title, fc.category_id, ca.name as ca_name 
	from rental r
	join inventory i
	on r.inventory_id = i.inventory_id
	join film f
	on i.film_id = f.film_id 
	join film_category fc
	on i.film_id = fc.film_id
	join category ca
	on fc.category_id = ca.category_id),
	
how_many_rents
as (select title, ca_name as genre, count(rental_id) as how_many_rented 
	from rented_films
	group by title, genre
	order by genre, how_many_rented desc
	)
select title, genre 
from (select title, genre, row_number() over(partition by genre) as tops
	from how_many_rents)
where tops <= 3


--5. Calculate the number of films released each year and cumulative total by the number of films. Write
--two query versions, one with window functions, the other without.

--a) without
with
rented_films 
as (select /*distinct(f.film_id)*/ r.rental_id, pa.payment_id, i.film_id, f.title, f.release_year, pa.amount 
	from rental r
	join inventory i
	on r.inventory_id = i.inventory_id
	join film f
	on i.film_id = f.film_id
   	join payment pa
   	on pa.rental_id = r.rental_id),
release_year_count
as (select release_year, count(film_id) as number_of_films 
	from rented_films
	group by release_year),
cumulative_total
as (select release_year, sum(amount)
	from rented_films  
	group by release_year)

select ct.release_year, ryc.number_of_films, ct.sum
from release_year_count ryc
join cumulative_total ct
on ryc.release_year = ct.release_year
order by release_year


--b) with


--6. Calculate a monthly statistics based on “rental_date” field from “Rental” table that for each month
--will show the percentage of “Animation” films from the total number of rentals. Write two query
--versions, one with window functions, the other without.


--7. Write a query that will return the names of actors who have starred in “Action” films more than in “Drama” film.

with action_drama_actor 
as ( 
	select fa.actor_id, fa.film_id, ca.name as genre
	from film_actor fa
	join film_category fc
	on fa.film_id = fc.film_id
	join category ca
	on ca.category_id = fc.category_id
	where ca.name in ('Action', 'Drama')
	),
action_actors
as (
	select actor_id, count(film_id) as roles_in_actions, genre
	from action_drama_actor
	group by actor_id, genre
	having genre = 'Action'
	),
drama_actors
as (
	select actor_id, count(film_id) as roles_in_dramas, genre
	from action_drama_actor
	group by actor_id, genre
	having genre = 'Drama'
	)
	
select ac.first_name || ' ' || ac.last_name as full_name,
		da.actor_id, da.roles_in_dramas, aa.roles_in_actions
from drama_actors da
join action_actors aa
on da.actor_id = aa.actor_id
join actor ac
on da.actor_id = ac.actor_id
where roles_in_dramas < roles_in_actions

--8. Write a query that will return the top-5 customers who spent the most money watching Comedies.
with rented_comedies
as (
	select re.rental_id, re.customer_id, inv.inventory_id, film.film_id, film.title
	from rental re
	join inventory inv
	on re.inventory_id = inv.inventory_id
	join film
	on inv.film_id = film.film_id
	join film_category fc
	on fc.film_id = film.film_id
	join category ca
	on fc.category_id = ca.category_id
	where ca.name = 'Comedy'
	)

select f.customer_id, sum(amount) as spent_on_comedies, cs.first_name || ' ' || cs.last_name as full_name
from(
	select pa.customer_id, pa.rental_id, pa.amount, rc.title
	from payment pa
	join rented_comedies rc
	on pa.rental_id = rc.rental_id) f
join customer cs
on f.customer_id = cs.customer_id
group by f.customer_id, cs.first_name, cs.last_name 
order by spent_on_comedies desc
limit 5


--9. In the “Address” table, in the “address” field, the last word indicates the "type" of a street: Street,
--Lane, Way, etc. Write a query that will return all "types" of streets and the number of addresses
--related to this "type".


select street_type, count(address) as number_of_addresses_of_this_type
from (select address_id, address,
	  split_part(address, ' ', -1) as street_type
	  from address)
group by street_type


--10. Write a query that will return a list of movie ratings, indicate for each rating the total number of
--films with this rating, the top-3 categories by the number of films in this category and the number of
--film in this category with this rating.
with
ratings
as (select distinct(rating) from film),
count_films_of_rating
as (select rating, count(film_id) as total
	from film
	group by rating),
	
film_rating_genre
as (select f.film_id, f.title, f.rating, ca.name as genre
	from film f
	join film_category fc
	on f.film_id = fc.film_id
	join category ca
	on fc.category_id = ca.category_id)

select count_films_of_rating.rating, count_films_of_rating.total,
top_genres_among_ratings.genre || ': ' || top_genres_among_ratings.cnt as category_of_tops
from (select *,
		row_number() over (partition by rating order by cnt desc) as category1
		from (select rating, genre, count(film_id) as cnt 
			from film_rating_genre
			group by rating, genre)
	  ) top_genres_among_ratings
join count_films_of_rating
on top_genres_among_ratings.rating = count_films_of_rating.rating
where category1 <= 3
order by rating, total desc
