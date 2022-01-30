pub type Item {
  Item(id: Int, completed: Bool, text: String)
}

pub fn get_text(item: Item) -> String {
  item.text
}
