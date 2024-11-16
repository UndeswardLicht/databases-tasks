--1. Create a separate db
create database postgres_task ;

--2,3. Creating tables, adding constraints and the pimary keys
create table Climb(
	id int primary key unique not null,
	start_date date not null,
	end_date date not null
);

create table Climbers(
	passport_id int primary key unique not null,
	first_name text,
	last_name text,
	address text
);

create table Mountains(
	id int primary key unique not null,
	mountain_name text,
	mountain_height int default(1000),
	mountain_hight_km int generated always as (mountain_height * 0.001) stored,
	location_id int
);

create table Route(
	id int primary key unique not null,
	route_name text,
	route_length int default(500),
	mountain_id int
);

create table Locations(
	id int primary key unique not null,
	country text,
	area_county text
);

--Creating also joint tables sith composite primary key 
create table Climbing_climbers_joint_table(
	climb_id int,
	climber_id int,
	primary key(climb_id, climber_id)
);

create table Climbing_mountains_joint_table(
	climb_id int,
	mountain_id int,
	primary key(climb_id, mountain_id)

);

create table Climbing_route_joint_table(
	climb_id int,
	route_id int,
	primary key(climb_id, route_id)

);

-- 4. Adding the referencing aka foreign keys using ALTER

alter table Mountains
	add constraint fk_location_id foreign key (location_id) references locations(id); 
	
alter table Route
	add constraint fk_mountain_id foreign key (mountain_id) references Mountains(id); 

alter table Climbing_climbers_joint_table
	add constraint fk_climb_id foreign key (climb_id) references climb(id); 

alter table Climbing_climbers_joint_table
	add constraint fk_climber_id foreign key (climber_id) references climbers(passport_id);

alter table Climbing_mountains_joint_table
	add constraint fk_climb_id foreign key (climb_id) references climb(id); 

alter table Climbing_mountains_joint_table
	add constraint fk_mountain_id foreign key (mountain_id) references mountains(id);

alter table Climbing_route_joint_table
	add constraint fk_climb_id foreign key (climb_id) references climb(id); 

alter table Climbing_route_joint_table
	add constraint fk_route_id foreign key (route_id) references route(id);

--5.  Apply five check constraints across the tables to restrict certain values.
--(some of the check constraints were already added, like: UNIQUE and NOT NULL,
--as for the check for a specific value - there is no column to add that really...)

alter table Climb
	add constraint check_start_date check (start_date > '2000-01-01');
	
alter table Climb
	add constraint check_end_date check (end_date > '2000-01-01');

alter table Climb
	add constraint check_start_smaller_than_end check (end_date > start_date);

alter table Mountains
	add constraint check_if_height_positive check (mountain_height > 0);

alter table Route
	add constraint check_if_route_positive check (route_length > 0);

--6. Populate the tables with the sample data generated,
--ensuring each table has at least two rows (for a total of 20+ rows in all the tables)

insert into Climb (id, start_date, end_date)
values (1, '2014-08-03', '2014-09-03'),
(2, '2020-10-03', '2020-10-13');

insert into Climbers (passport_id, first_name, last_name, address)
values (678162, 'Sherlock', 'Holmes', 'Baker str., 221b'),
(912393,'Johnny', 'B-Good', 'Longest ave, 99');

insert into Locations (id, country, area_county)
values (1, 'Georgia', 'Samegrelo-Zemo Svaneti'),
(2, 'Poland', 'Podhale');

insert into Mountains (id, mountain_name, mountain_height, location_id)
values (1, 'Shkhara', 5100, 1),
(2, 'Rysy', 2500, 2);

insert into Route (id, route_name, route_length, mountain_id)
values (1, 'Happy Route', 700, 2),
(2, 'Route of doom', 1000, 1);

insert into Climbing_climbers_joint_table (climb_id, climber_id)
values (1, 912393),
(2, 912393);

insert into Climbing_mountains_joint_table (climb_id, mountain_id)
values (1, 2),
(2, 1);

insert into Climbing_route_joint_table (climb_id, route_id)
values (2, 2),
(1, 1);

--7. Add a 'record_ts' field to each table using ALTER TABLE statements,
--set the default value to current_date, and check
--to make sure the value has been set for the existing rows.

alter table Climb
	add column record_ts date default current_date;
	
alter table Climbers
	add column record_ts date default current_date;
	
alter table Mountains
	add column record_ts date default current_date;

alter table Route
	add column record_ts date default current_date;

alter table Locations
	add column record_ts date default current_date;

alter table Climbing_climbers_joint_table
	add column record_ts date default current_date;

alter table Climbing_mountains_joint_table
	add column record_ts date default current_date;
	
alter table Climbing_route_joint_table
	add column record_ts date default current_date;
	