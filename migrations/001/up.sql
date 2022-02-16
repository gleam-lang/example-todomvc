create table users (
  id serial primary key
);

create table items (
  id serial primary key,
  completed boolean not null default false,
  content varchar(3000) not null,
  user_id integer references users (id)
);

create index items_user_id_completed 
on items (
  user_id, 
  completed
);
