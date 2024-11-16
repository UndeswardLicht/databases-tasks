-- 1. Create a new user with the username "rentaluser" and the password "rentalpassword".
-- Give the user the ability to connect to the database but no other permissions.
DROP ROLE IF EXISTS rentaluser;

CREATE ROLE rentaluser
LOGIN PASSWORD 'rentalpassword';
grant connect on database dvdrental to rentaluser; 

-- 2. Grant "rentaluser" SELECT permission for the "customer" table.
--Сheck to make sure this permission works correctly—write a SQL query to select all customers.

grant select on table customer to rentaluser;

SELECT SESSION_USER, CURRENT_USER;
set role 'rentaluser';
select * from customer;
select * from film;
reset role;

--3. Create a new user group called "rental" and add "rentaluser" to the group. 

create role rental;
grant rental to rentaluser;

--4. Grant the "rental" group INSERT and UPDATE permissions for the "rental" table.
-- Insert a new row and update one existing row in the "rental" table under that role. 

grant insert, update on table rental to rental;

set role 'rentaluser';

insert into rental
values(33100, current_timestamp, 1, 1, current_timestamp, 1);


--next query will fail as those user + roles don't have SELECT privilege. As from PostgreSQL official doc:
	--"In practice, any nontrivial UPDATE command will require SELECT privilege as well,
	--since it must reference table columns to determine which rows to update,
	--and/or to compute new values for columns. https://www.postgresql.org/docs/9.1/sql-grant.html"
update rental
set staff_id = 5
where rental_id = 3;

reset role;

delete from rental
where rental_id = 33100

--5. Revoke the "rental" group's INSERT permission for the "rental" table.
-- Try to insert new rows into the "rental" table make sure this action is denied.

revoke insert on table rental from rental;
set role 'rentaluser';

insert into rental
values(33100, current_timestamp, 1, 1, current_timestamp, 1);

reset role;

--6. Create a personalized role for any customer already existing in the dvd_rental database.
-- The name of the role name must be client_{first_name}_{last_name} (omit curly brackets). 
-- The customer's payment and rental history must not be empty. Configure that role so that the customer
-- can only access their own data in the "rental" and "payment" tables.
-- Write a query to make sure this user sees only their own data.

alter table rental enable row level security;
alter table payment enable row level security;

create group client_roles;

create view customers_names
as select customer_id, 'client' || '_' || first_name || '_' || last_name as full_name
from customer;

-- actually I didn't finish this task as I couldn't find a way where to go next,
--so there are only my sketches and thoughts on how would I do that 

create policy can_view_only_their_rental on rental
for select to client_roles
using (customer_id = current_user);

create policy can_view_only_their_payment on payment
for select to client_roles;

do 
$$
declare
	rec record;
begin
	for r in
	select 'client' || '_' || first_name || '_' || last_name as full_name
	from customer
	loop 
	var_full_name = full_name;
	create_role var_full_name;
	alter group add user var_full_name;

end;
$$
