--1. Choose one of your favorite films and add it to the "film" table. Fill in rental rates with 4.99 and rental durations with 2 weeks.

insert into film(title, rental_duration, rental_rate, language_id)
values ('PINK PANTER', 14, 4.99, 1);


--2. Add the actors who play leading roles in your favorite film to the "actor" and "film_actor" tables (three or more actors in total).

insert into actor(first_name, last_name)
values ('STEVE', 'MARTIN'),
		('JEAN', 'RENO'),
		('PETER', 'SELLERS');

insert into film_actor(actor_id, film_id)
values (201, 1001),
		(202,1001),
		(203, 1001);
		
--3. Add your favorite movies to any store's inventory.

insert into inventory(film_id, store_id)
values (1001, 2);
