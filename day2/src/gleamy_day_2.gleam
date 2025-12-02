import gleam/io
import gleam/string
import gleam/int
import gleam/result
import gleam/list
import gleam/order
import simplifile

pub fn main() -> Nil {
  io.println("Hello from gleamy_day_2!")
  //let filepath = "./sample.txt"
  let filepath = "./part1.txt"
  let assert Ok(file) = simplifile.read(from: filepath)
  echo file
  file
  |> string.split(",")
  |> check_for_patterns
  |> echo
  Nil
}

fn check_for_patterns(ranges: List(String)) -> #(Int, Int){
  check_for_patterns_loop(ranges, 0, 0)
}

fn check_for_patterns_loop(
  ranges: List(String),
  invalid_sum: Int,
  invalid_pattern_2: Int,
) -> #(Int, Int) {
  case ranges {
    [] -> #(invalid_sum, invalid_pattern_2)
    [first_range, ..the_rest_of_the_ranges] -> {
      let parts = string.split(first_range, "-")
      let start = list.first(parts) |> result.unwrap("")
      let end = list.first(list.drop(parts, 1)) |> result.unwrap("")
      let start_int = int.parse(start) |> result.unwrap(0)
      let end_int = int.parse(end) |> result.unwrap(0)
      let invalid_pattern1 = list.range(start_int, end_int + 1) 
      |> list.map(fn(x) { 
        let number = int.to_string(x) 
        case string.length(number) |> int.is_odd {
          True -> {
            0
          }
          False -> {
            invalid_pattern1(number)
          }
        }
      })
      let diff_length_patterns = list.range(start_int, end_int + 1)
        |> list.map(fn(x) { 
          invalid_pattern2(int.to_string(x))
        }) |> list.fold(0, int.add)
      let invalid_count = invalid_pattern1 |> list.fold(0, int.add)
      check_for_patterns_loop(the_rest_of_the_ranges, invalid_sum+invalid_count, invalid_pattern_2 + diff_length_patterns)
    }
  }
}

fn invalid_pattern1(number: String)-> Int {
  let half_length = int.divide(string.length(number), 2) |> result.unwrap(0)
  let first_half = string.slice(number, 0, half_length)
  let second_half = string.slice(number, half_length, string.length(number))
  case string.compare(first_half,second_half) {
    order.Eq -> {
      int.parse(number) |> result.unwrap(0)}
    _ -> 0
  }
}


fn invalid_pattern2(number: String) -> Int {
  invalid_pattern2_loop(number, 1)
}

fn invalid_pattern2_loop(
  number: String,
  index: Int,
) -> Int {
  let max = string.length(number)
  let pattern = string.slice(number, 0, index)
  let repeat = string.length(number)/string.length(pattern)
  case index, string.compare(string.repeat(pattern, repeat),number) {
    index, _ if index >= max -> 0
    _, order.Eq -> {
      int.parse(number) |> result.unwrap(0)
    }

    _, _ -> invalid_pattern2_loop(number, index + 1)
  }
}


