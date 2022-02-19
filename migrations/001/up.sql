create table users (
  id serial primary key
);

create table items (
  id serial primary key,
  inserted_at timestamp default now(),
  completed boolean not null default false,
  content varchar(500) not null,
  user_id integer references users (id)
);

create index items_user_id_completed 
on items (
  user_id, 
  completed
);
