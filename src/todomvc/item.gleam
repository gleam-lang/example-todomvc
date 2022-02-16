pub type Item {
  Item(id: Int, completed: Bool, content: String)
}

pub fn get_counts() -> Nil {
  "
SELECT 
  completed,
  count(*)
FROM
  items
WHERE
  item.user_id = $1
GROUP BY
  completed
"
  todo
}
