--Which staff members
--made the highest revenue
--for each store and deserve a bonus for the year 2017?
--1.

select s.staff_id, s.store_id, rev.sum_amount
from staff s
join (select staff_id, sum(amount) as sum_amount 
					from payment pa
					group by staff_id) rev
on s.staff_id = rev.staff_id
order by sum_amount desc
limit 2;


--Which five movies
--were rented more than the others,
--and what is the expected age of the audience for these movies?
--1. 
with rented_films as (select r.rental_id, i.inventory_id, f.film_id, f.title, f.rating
						from rental r
						join inventory i
						on r.inventory_id = i.inventory_id
						join film f
						on i.film_id = f.film_id)
select rented_films.title, rented_films.rating, count(rented_films.rental_id) as rents
from rented_films
group by rented_films.title,  rented_films.rating
order by rents desc
limit 5


--Which actors/actresses
--didn't act for a longer period of time
--than the others?
--1. 
with actor_films as (select ac.actor_id, ac.first_name || ' ' || ac.last_name as full_ac_name, fi.release_year, fi.film_id, fi.title
					from film_actor fa
					join film fi 
					on fi.film_id = fa.film_id
					join actor ac
					on ac.actor_id = fa.actor_id
					order by full_ac_name, release_year
					)
					
select full_ac_name, time_distance
from 	(select af.actor_id, af.full_ac_name, af.release_year, af.title,
		af.release_year - lag(af.release_year)
	  	over (partition by actor_id order by release_year) as time_distance 
		from
				(select ac.actor_id, ac.first_name || ' ' || ac.last_name as full_ac_name, fi.release_year, fi.film_id, fi.title
				from film_actor fa
				join film fi 
				on fi.film_id = fa.film_id
				join actor ac
				on ac.actor_id = fa.actor_id
				order by full_ac_name, release_year) af)

where time_distance IS NOT NULL
order by time_distance desc
limit 2

