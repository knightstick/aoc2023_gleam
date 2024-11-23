import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

import simplifile.{read}

pub fn main() {
  let assert Ok(input) = read("inputs/day1.txt")

  input
  |> string.trim
  |> day1_part1
  |> int.to_string
  |> io.println

  input
  |> string.trim
  |> day1_part2
  |> int.to_string
  |> io.println
}

fn day1_part1(input: String) -> Int {
  input
  |> string.split("\n")
  |> list.map(digits)
  |> sum
}

fn day1_part2(input: String) -> Int {
  input
  |> string.split("\n")
  |> list.map(digits2)
  |> sum
}

fn sum(list) -> Int {
  list
  |> list.fold(0, fn(x, acc) { x + acc })
}

fn digits(line: String) -> Int {
  let assert Some(digs) =
    line
    |> string.to_graphemes
    |> list.map(maybe_digit)
    |> list.filter(option.is_some)
    |> option.all

  let assert Ok(first) = list.first(digs)
  let assert Ok(last) = list.last(digs)

  result.unwrap(int.parse(int.to_string(first) <> int.to_string(last)), 0)
}

fn digits2(line: String) -> Int {
  let digs =
    line
    |> string.to_graphemes
    |> collect_digits2([])
    |> list.reverse

  let assert Ok(first) = list.first(digs)
  let assert Ok(last) = list.last(digs)

  result.unwrap(int.parse(int.to_string(first) <> int.to_string(last)), 0)
}

fn maybe_digit(char: String) -> Option(Int) {
  case int.parse(char) {
    Error(_) -> None
    Ok(i) -> Some(i)
  }
}

fn collect_digits2(str: List(String), acc: List(Int)) -> List(Int) {
  case str {
    [] -> acc
    [_, ..xs] -> {
      let dig = case str {
        ["o", "n", "e", ..] -> Some(1)
        ["t", "w", "o", ..] -> Some(2)
        ["t", "h", "r", "e", "e", ..] -> Some(3)
        ["f", "o", "u", "r", ..] -> Some(4)
        ["f", "i", "v", "e", ..] -> Some(5)
        ["s", "i", "x", ..] -> Some(6)
        ["s", "e", "v", "e", "n", ..] -> Some(7)
        ["e", "i", "g", "h", "t", ..] -> Some(8)
        ["n", "i", "n", "e", ..] -> Some(9)
        ["z", "e", "r", "o", ..] -> Some(0)
        ["1", ..] -> Some(1)
        ["2", ..] -> Some(2)
        ["3", ..] -> Some(3)
        ["4", ..] -> Some(4)
        ["5", ..] -> Some(5)
        ["6", ..] -> Some(6)
        ["7", ..] -> Some(7)
        ["8", ..] -> Some(8)
        ["9", ..] -> Some(9)
        ["0", ..] -> Some(0)
        _ -> None
      }

      case dig {
        None -> collect_digits2(xs, acc)
        Some(dig) -> collect_digits2(xs, [dig, ..acc])
      }
    }
  }
}
