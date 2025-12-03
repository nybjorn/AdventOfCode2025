import argv
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/result
import gleam/string
import iterators
import simplifile

pub fn main() -> Nil {
  io.println("Hello from gleamy_day_1!")
  //let filepath = "./day1.txt"
  //let filepath = "./1000.txt"
  //let filepath = "./L50.txt"
 // let filepath = "./50.txt"
  let filepath = "./part1.txt"
  let assert Ok(file) = simplifile.read(from: filepath)
  let dial_position = 50
  case argv.load().arguments {
    ["part1"] -> {
      file
      |> string.split("\n")
      |> turn_dial(dial_position)
      |> echo
    }
    ["part2"] -> {
      part2(file |> string.split("\n"), dial_position)
      |> echo
    }
    _ -> {
      io.println("Usage:  part1 | part2")
      -1
    }
  }

  Nil
}

fn part2(turns: List(String), dial_position: Int) -> Int {
  turn_dial_2(turns, dial_position, 0)
}

fn turn_dial_2(turns: List(String), dial_position: Int, clicks: Int) -> Int {
  turn_dial_2_loop(turns, dial_position, clicks)
}

fn turn_dial_2_loop(turns: List(String), dial_position: Int, clicks: Int) -> Int {
  echo "Dial position: " <> int.to_string(dial_position) <> " Clicks: " <> int.to_string(clicks)
  case turns {
    [] -> clicks
    [turn, ..the_rest_of_the_turns] -> {
      let direction = string.slice(turn, 0, 1)
      let dial = list.range(0, 99)
      // Did not find any sinester way to move so lets just reverse the list for left turns
      let tes = case string.compare(direction, "L") {
        order.Eq -> iterators.cycle(dial |> list.reverse()) |> iterators.skip(99-dial_position )
        _ -> iterators.cycle(dial) |> iterators.skip(dial_position)
      }
     
      let number_string = string.slice(turn, 1, string.length(turn))
      let number = int.parse(number_string) |> result.unwrap(0)
      // start with turn 0 == starting position 
      let turns = iterators.from_list(list.range(0, number))
      let turned =
        iterators.zip(tes , turns)
        |> iterators.to_list
      echo turned
      let new_clicks =
        turned |> list.drop(1)
        |> list.filter(fn(x) {
          case x.0 {
            0 -> True
            _ -> False
          }
        }) |> list.length() 
      let new_dial_position = turned |> list.last |> result.unwrap(#(0, 0))

      turn_dial_2(the_rest_of_the_turns, new_dial_position.0, clicks + new_clicks)
    }
  }
}

fn turn_dial(turns: List(String), dial_position: Int) -> Int {
  turn_dial_loop(turns, dial_position, 0)
}

fn turn_dial_loop(turns: List(String), dial_position: Int, password: Int) -> Int {
  case turns {
    [] -> password
    [first_turn, ..the_rest_of_the_turns] -> {
      case dial_position {
        x if x < 0 || x > 99 -> {
          echo "Error: Dial position out of bounds: " <> int.to_string(x)
          panic
        }
        _ -> Nil
      }
      let operation = case string.slice(first_turn, 0, 1) {
        "L" -> int.subtract
        _ -> int.add
      }
      let number_string = string.slice(first_turn, 1, string.length(first_turn))
      let number = int.parse(number_string) |> result.unwrap(0)
      let new_dial_position =
        dial_position
        |> operation(number)
        |> int.modulo(100)
        |> result.unwrap(0)

      turn_dial_loop(
        the_rest_of_the_turns,
        new_dial_position,
        password
          + {
          case new_dial_position {
            0 -> 1
            _ -> 0
          }
        },
      )
    }
  }
}
