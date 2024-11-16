--1. Write a script to create the following database.
-- The table “Orders” has “o_id” as a primary key. The table “Products” has “p_name” as a primary
-- key. The table “Order_Items” has a composite primary key: “order_id” plus “product_name”. All
-- fields must be not null. The default value for the “amount” field is 1, and the field can only contain
-- positive values.

create table Orders(
	o_id serial primary key not null,
	order_date date not null
);

create table Products(
	p_name text primary key not null,
	price money not null
);

create table Order_items(
	order_id int not null,
	product_name text not null,
	amount numeric(7,2) not null check (amount > 0) default 1,
	primary key(order_id, product_name),
	constraint fk_order_id foreign key(order_id) references orders(o_id),
	constraint fk_product_name foreign key(product_name) references products(p_name)
);

--2. Add following values to the created tables:
-- Two orders to the “Orders” table with any dates.
-- Two products to the “Products” table with names “p1” and “p2”, and prices on your choice.
-- First order contains “p1” and “p2” products with default amount.
-- The second order contains “p1” and "p2" products with amounts on your choice.

insert into Orders (order_date)
values ('2014-08-03'),
		('2021-01-07');
		
insert into Products (p_name, price)
values ('p1', 2500),
		('p2', 30000);
		
insert into Order_items (order_id, product_name, amount)
values (1, 'p1', default),
		(1, 'p2', default),
		(2, 'p1', 7),
		(2, 'p2', 5);
			
--3. Write a script that modifies the database. The database should undergo the following changes:
-- - All new fields must be not null.
-- - The primary key of the “Products” table should be
--the field “p_id” with the serial type.
-- - Values of the “p_name” field must be unique.
-- - Add fields “price” and “total” to the “Order_Items” table.
-- - Copy the corresponding values from Products.price to Order_Items.price.
-- - In the “total” field, write the product of amount and price, and add a constraint that checks that
-- total = amount * price.

alter table Order_items
drop constraint fk_product_name;

alter table Products
drop constraint products_pkey;

alter table Products
add column p_id serial primary key not null;


alter table Order_items
add column price money not null default 0;

UPDATE Order_items
SET price = products.price 
FROM Products 
WHERE order_items.product_name = products.p_name;

alter table Order_items
add column total money not null generated always as (price * amount) stored;

alter table Products
add constraint unique_to_p_name unique(p_name);



alter table Order_items
drop constraint order_items_pkey;

alter table Order_items
add column product_id int not null default 0;

UPDATE Order_items
SET product_id = products.p_id 
FROM Products 
WHERE order_items.product_name = products.p_name;

alter table Order_items
add primary key(order_id, product_id);

alter table Order_items
drop column product_name;

alter table Order_items
add constraint fk_product_id foreign key(product_id) references products(p_id);


--4. . Write commands to update data in the database:

-- - Rename the product with the name “p1” to “product1”.
update Products
set p_name = 'product1'
where p_name = 'p1';

-- - Remove the product with the name “p2” from the first order. When writing the update
-- command, do not use the value of “p_id” field.
delete from Order_items
where order_id = 1 AND price = (select price from Products where p_name = 'p2');

-- - Delete the second order from the database.
delete from order_items
where order_id = 2;
delete from orders 
where o_id = 2;

-- - Change the price of the product “product1” to 5, don't forget to update the “Order_items”
-- table.
update Products
set price = 5
where p_name = 'product1';

update Order_items
set price = 5
where product_id = (select p_id from Products where p_name = 'product1');

-- - Add a new order with the current date. Specify that 3 units of “product1” were purchased in
-- this order. When adding data to the “Order_items” table, do not use explicitly the value of
-- “p_id” field).
insert into Orders(order_date)
values (current_date);

insert into Order_items(order_id, amount, product_id, price)
values ((select o_id from Orders where order_date = current_date), 
		3,
		(select p_id from Products where p_name = 'product1'),
		(select price from Products where p_name = 'product1')
	   );
