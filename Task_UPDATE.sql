--1. Alter the rental duration and rental rates of the film you inserted before to three weeks and 9.99, respectively.

select * from film
WHERE CAST(last_update AS DATE) = '2024-06-03'

update film
set rental_duration = 21, rental_rate = 9.99
where cast(last_update as date) = '2024-06-03'

--2. Alter any existing customer in the database with at least 10 rental and 10 payment records.
--Change their personal data to yours (first name, last name, address, etc.).
--You can use any existing address from the "address" table.
-- Please do not perform any updates on the "address" table, as this can impact multiple records with the same address.


--Since the number of rental and payment records here are the same - i used only one 
with top_rental as (select customer_id, count(rental_id) as number_of_rentals from rental
					group by customer_id
					order by number_of_rentals desc
					limit 1)
update customer
set first_name = 'ALIAKSEI', last_name = 'BUSLEIKA', address_id = 604, email = 'LALALAND@landoflala.org'
where customer_id = (select customer_id from top_rental)

--3. Change the customer's create_date value to current_date.

update customer
set create_date = current_date
where first_name = 'ALIAKSEI'
