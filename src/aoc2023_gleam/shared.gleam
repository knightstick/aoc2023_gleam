import gleam/list
import simplifile

pub fn sum(list) -> Int {
  list
  |> list.fold(0, fn(x, acc) { x + acc })
}

pub fn read(path: String) -> String {
  let assert Ok(input) = simplifile.read(path)

  input
}
