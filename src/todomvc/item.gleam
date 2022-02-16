pub type Item {
  Item(id: Int, completed: Bool, content: String)
}

pub fn get_counts() -> Nil {
  "
select 
  completed,
  count(*)
from
  items
where
  item.user_id = $1
group by
  completed
"
  todo
}

pub fn insert_item() -> Nil {
  "
insert into items
  (content, user_id) 
values 
  ($1, $2)
"
  todo
}

pub fn list_items() -> Nil {
  "
select
  id,
  user_id,
  content
from
  items
where
  user_id = $1
"
  todo
}

pub fn delete_item() -> Nil {
  "
delete from
  items
where
  id = $1
and
  user_id = $2
"
  todo
}

pub fn toggle_completion() -> Nil {
  "
update
  items
set
  completed = not completed
where
  id = $1
and
  user_id = $2
returning
  completed
"
  todo
}
