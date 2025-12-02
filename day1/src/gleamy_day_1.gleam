import gleam/int
import gleam/io
import gleam/result
import gleam/string
import simplifile

pub fn main() -> Nil {
  io.println("Hello from gleamy_day_1!")
  let filepath = "./day1.txt"
  //let filepath = "./1000.txt"
  //let filepath = "./L50.txt"
  //let filepath = "./50.txt"
  //let filepath = "./part1.txt"
  let assert Ok(file) = simplifile.read(from: filepath)
  let dial_position = 50
  file
  |> string.split("\n")
  |> turn_dial(dial_position)
  |> echo

  Nil
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
