import aoc2023_gleam/shared.{sum}
import gleam/int
import gleam/io
import gleam/list
import gleam/string

const example = "
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
"

pub fn main() {
  example
  |> part1
  |> io.debug

  let input =
    "inputs/day2.txt"
    |> shared.read

  input
  |> part1
  |> io.debug

  example
  |> part2
  |> io.debug

  input
  |> part2
  |> io.debug
}

fn part1(input: String) {
  input
  |> parse
  |> list.filter(is_possible)
  |> list.map(fn(game) { game.id })
  |> sum
}

fn part2(input: String) {
  input
  |> parse
  |> list.map(fewest_cubes)
  |> list.map(power)
  |> sum
}

fn parse(input: String) -> List(Game) {
  input
  |> string.trim
  |> string.split(on: "\n")
  |> list.map(parse_game)
}

type Game {
  Game(id: Int, rounds: List(Round))
}

type Round =
  List(#(String, Int))

fn parse_game(line: String) {
  let assert Ok(#(game, balls)) = string.split_once(line, on: ": ")
  let assert Ok(#(_, id)) = string.split_once(game, on: " ")
  let rounds = string.split(balls, on: "; ")
  let rounds = list.map(rounds, parse_round)
  let assert Ok(id) = int.parse(id)

  Game(id, rounds)
}

fn parse_round(line: String) {
  line
  |> string.split(on: ", ")
  |> list.map(parse_ball)
}

fn parse_ball(str: String) -> #(String, Int) {
  let assert Ok(#(count, color)) = string.split_once(str, on: " ")
  let assert Ok(count) =
    count
    |> int.parse

  #(color, count)
}

fn is_possible(game: Game) -> Bool {
  game.rounds
  |> list.all(is_round_possible)
}

fn is_round_possible(round: Round) -> Bool {
  round
  |> list.all(is_pull_possible)
}

fn is_pull_possible(pull: #(String, Int)) -> Bool {
  case pull {
    #("red", count) if count <= 12 -> True
    #("green", count) if count <= 13 -> True
    #("blue", count) if count <= 14 -> True
    _ -> False
  }
}

type FewestCubes {
  FewestCubes(red: Int, green: Int, blue: Int)
}

fn fewest_cubes(game: Game) -> FewestCubes {
  game.rounds
  |> list.fold(FewestCubes(0, 0, 0), fn(cubes: FewestCubes, round: Round) {
    round
    |> list.fold(cubes, fn(cubes: FewestCubes, pull: #(String, Int)) {
      let #(color, count) = pull
      case color {
        "red" -> {
          case count {
            count if count > cubes.red -> FewestCubes(..cubes, red: count)
            _ -> cubes
          }
        }
        "green" -> {
          case count {
            count if count > cubes.green -> FewestCubes(..cubes, green: count)
            _ -> cubes
          }
        }
        "blue" -> {
          case count {
            count if count > cubes.blue -> FewestCubes(..cubes, blue: count)
            _ -> cubes
          }
        }
        _ -> cubes
      }
    })
  })
}

fn power(cubes: FewestCubes) -> Int {
  cubes.red * cubes.green * cubes.blue
}
