import aoc2023_gleam/shared
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

const example = "
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
"

pub fn main() {
  example
  |> part1
  |> io.debug

  "inputs/day3.txt"
  |> shared.read
  |> part1
  |> io.debug
}

type Grid =
  List(CoordCell)

type CoordCell =
  #(Coord, Cell)

type Coord =
  #(Int, Int)

type Cell {
  Empty
  Symbol
  Number(Int)
}

fn part1(input: String) -> Int {
  let grid =
    input
    |> parse

  let run = fn(acc, cell) { run(grid, cell, acc) }

  grid
  |> list.fold(Acc(current: #(None, False), res: []), run)
  |> fn(acc) { acc.res }
  |> int.sum
}

type Acc {
  Acc(current: #(Option(Int), Bool), res: List(Int))
}

fn run(grid: Grid, cell: CoordCell, acc: Acc) {
  let #(coord, cell) = cell
  let Acc(current: #(running_number, has_symbol_neighbor), res: res) = acc

  case cell, running_number, has_symbol_neighbor {
    // A number just finished, and is a part number
    Empty, Some(number), True ->
      Acc(current: #(None, False), res: [number, ..res])
    // A number just finished, and ends with a symbol, so is a part number
    Symbol, Some(number), _ ->
      Acc(current: #(None, False), res: [number, ..res])
    // Start a new number, check neighbors
    Number(digit), None, _ ->
      Acc(current: #(Some(digit), any_symbol_neighbor(grid, coord)), res: res)
    // Continue a number, either already "tagged" or check neighbors
    Number(digit), Some(running), has_symbol_neighbor -> {
      let symbol_neighbor =
        has_symbol_neighbor || any_symbol_neighbor(grid, coord)
      Acc(current: #(Some(running * 10 + digit), symbol_neighbor), res: res)
    }
    // Start over
    _, _, _ -> Acc(current: #(None, False), res: res)
  }
}

fn parse(input: String) -> Grid {
  input
  |> string.trim
  |> string.split(on: "\n")
  |> list.index_map(parse_row)
  |> list.flatten
}

fn parse_row(line: String, row: Int) -> List(CoordCell) {
  line
  |> string.to_graphemes
  |> list.index_map(fn(char, col) { parse_cell(row, col, char) })
}

fn parse_cell(row: Int, col: Int, char: String) -> CoordCell {
  let coord = #(row, col)
  let cell = parse_char(char)

  #(coord, cell)
}

fn parse_char(char: String) -> Cell {
  case char {
    "." -> Empty
    "0" -> Number(0)
    "1" -> Number(1)
    "2" -> Number(2)
    "3" -> Number(3)
    "4" -> Number(4)
    "5" -> Number(5)
    "6" -> Number(6)
    "7" -> Number(7)
    "8" -> Number(8)
    "9" -> Number(9)
    _ -> Symbol
  }
}

fn any_symbol_neighbor(grid, coord) -> Bool {
  let #(row, col) = coord
  let neighbors = [
    #(row - 1, col - 1),
    #(row - 1, col),
    #(row - 1, col + 1),
    #(row, col - 1),
    #(row, col + 1),
    #(row + 1, col - 1),
    #(row + 1, col),
    #(row + 1, col + 1),
  ]

  neighbors
  |> list.any(fn(neighbor) {
    case get_cell(grid, neighbor) {
      Some(Symbol) -> True
      _ -> False
    }
  })
}

fn get_cell(grid: Grid, coord: Coord) -> Option(Cell) {
  grid
  |> list.key_find(coord)
  |> option.from_result
}
