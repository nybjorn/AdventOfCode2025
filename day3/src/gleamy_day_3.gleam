import argv
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() -> Nil {
  io.println("Hello from gleamy_day_3!")
  //let filepath = "./sample.txt"
  let filepath = "./part3.txt"
  let assert Ok(file) = simplifile.read(from: filepath)
  case argv.load().arguments {
    ["part1"] -> {
      file
      |> string.split("\n")
      |> part1()
      |> echo
    }
    ["part2"] -> {
      part2(file |> string.split("\n"))
      |> echo
    }
    _ -> {
      io.println("Usage:  part1 | part2")
      -1
    }
  }
  Nil
}

fn part2(battery_banks: List(String)) -> Int {
  part2_loop(battery_banks, 0)
}

fn part2_loop(battery_banks: List(String), joltage: Int) -> Int {
  case battery_banks {
    [] -> joltage
    [first_bank, ..the_rest_of_the_banks] -> {
      let batteries =
      first_bank
      |> string.to_graphemes()
      |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
      let max = max_with_x_left_calc (batteries, 11, "") |> int.parse |> result.unwrap(0)
      part2_loop(the_rest_of_the_banks, joltage + max )
    }
  }
}

fn max_with_x_left_calc(batteries: List(Int), x: Int, ints: String) -> String {
  case x {
    0 -> {
      let last = batteries |> list.max(int.compare) |> result.unwrap(0) |> int.to_string()
      ints <> last
    }
    _ -> {
      let max_with_x_left = batteries |> list.take(batteries |> list.length() |> int.subtract(x)) |> list.max(int.compare) |> result.unwrap(0)
      let batteries_to_the_right =
      batteries
      |> list.drop_while(fn(a) {
        case a {
          x if x != max_with_x_left -> True
          _ -> False
        }
      }) |> list.drop(1)
      max_with_x_left_calc(batteries_to_the_right, int.subtract(x, 1), ints <> max_with_x_left |> int.to_string())
      }
    }
  }


fn part1(turns: List(String)) -> Int {
  part1_loop(turns, 0)
}

fn part1_loop(battery_banks: List(String), joltage: Int) -> Int {
  case battery_banks {
    [] -> joltage
    [first_bank, ..the_rest_of_the_banks] -> {
      let batteries =
        first_bank
        |> string.to_graphemes()
        |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
      
      let max_battery = batteries |> list.max(int.compare) |> result.unwrap(0)
      let batteries_to_the_right =
        batteries
        |> list.drop_while(fn(a) {
          case a {
            x if x != max_battery -> True
            _ -> False
          }
        })
      let max_joltage = case
        list.length(batteries) == list.length(batteries_to_the_right)
      {
        True ->
          max_battery
          |> int.multiply(10)
          |> int.add(
            batteries_to_the_right
            |> list.drop(1)
            |> list.max(int.compare)
            |> result.unwrap(0),
          )
        _ ->
          case list.length(batteries_to_the_right) {
            1 -> {
              let remove_last = list.length(batteries) |> int.subtract(1)
              batteries
              |> list.take(remove_last)
              |> list.max(int.compare)
              |> result.unwrap(0)
              |> int.multiply(10)
              |> int.add(max_battery)
            }
            _ ->
              max_battery
              |> int.multiply(10)
              |> int.add(
                batteries_to_the_right
                |> list.drop(1)
                |> list.max(int.compare)
                |> result.unwrap(0),
              )
          }
      }
      
      part1_loop(the_rest_of_the_banks, joltage + max_joltage)
    }
  }
}
