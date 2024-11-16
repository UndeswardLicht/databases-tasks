--1. Remove a previously inserted film from the inventory and all corresponding rental records

delete from film_actor
WHERE CAST(last_update AS DATE) = '2024-06-03'

delete from inventory
WHERE CAST(last_update AS DATE) = '2024-06-03'

--2. Remove any records related to you (as a customer) from all tables except "Customer" and "Inventory"

begin;
delete from payment 
where customer_id = 148;

delete from rental 
where customer_id = 148;

rollback