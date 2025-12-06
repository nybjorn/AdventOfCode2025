import argv
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string
import gleam/time/duration
import gleam/time/timestamp
import simplifile

pub fn main() -> Nil {
  let start_time = timestamp.system_time()
  io.println("Hello from gleamy_day_6!")
  //let filepath = "./sample.txt"
  let filepath = "./part1.txt"
  let assert Ok(file) = simplifile.read(from: filepath)
  case argv.load().arguments {
    ["part1"] -> {
      let reg_exp = "\\S+"
      get_columns(file, reg_exp)
      |> calc
      |> echo
      "1️⃣  " |> io.print
    }
    ["part2"] -> {
      file
      |> make_a_map
      |> transform_to_same_format_as_part1
      |> calc
      |> echo

      "2️⃣  " |> io.print
    }
    _ -> {
      io.println("Usage:  part1 | part2")
    }
  }
  "🌟 " |> io.print
  time_consumed(timestamp.difference(start_time, timestamp.system_time()))
  Nil
}

fn make_a_map(file: String) -> dict.Dict(#(Int, Int), String) {
  file
  |> string.split("\n")
  |> list.index_fold(dict.new(), fn(acc, row, index) {
    string.to_graphemes(row)
    |> list.index_fold(acc, fn(acc, item, char_index) {
      acc |> dict.insert(#(index, char_index), item)
    })
  })
}

fn time_consumed(duration: duration.Duration) -> Nil {
  let approx = duration |> duration.approximate
  approx.0 |> int.to_string |> io.print
  case approx.1 {
    duration.Second -> io.println(" seconds")
    duration.Nanosecond -> io.println(" nanoseconds")
    duration.Minute -> io.println(" minutes")
    duration.Millisecond -> io.println(" milliseconds")
    duration.Microsecond -> io.println(" microseconds")
    _ -> panic
  }
}

fn transform_to_same_format_as_part1(board: dict.Dict(#(Int, Int), String)) {
  let max_x =
    board
    |> dict.keys
    |> list.map(fn(x) { x.0 })
    |> list.max(int.compare)
    |> result.unwrap(0)
  let max_y =
    board
    |> dict.keys
    |> list.map(fn(x) { x.1 })
    |> list.max(int.compare)
    |> result.unwrap(0)
  let column_nbr = list.range(max_y, 0)
  let row_nbr = list.range(0, max_x)
  column_nbr
    |> list.fold([], fn(acc, y) {
      let number =
        row_nbr
        |> list.map(fn(x) {
          case dict.get(board, #(x, y)) {
            Ok(x) -> x
            Error(_) -> panic as "Out of bounds"
          }
        })
        |> string.join("")
      let last_token = string.last(number) |> result.unwrap("")
      let fixed = case last_token {
        "*" | "+" -> [number |> string.drop_end(1) |> string.trim, last_token]
        _ -> [string.trim(number)]
      }
      acc |> list.append(fixed)
    })
    // list with number and operators and some blanks separating the columns
    |> list.filter(fn(x) { x != "" })
    // Chunk by operators to group numbers with their operators
    |> list.chunk(by: fn(n) { n == "+" || n == "*" }) 
    // Did not work as expected, so manually put the operators with the numbers
    |> list.fold([], fn(acc, item) { 
      case item |> list.length() {
        1 -> {
          let last_list = acc |> list.last |> result.unwrap([])
          let new_list = last_list |> list.append(item)
          let acc_length = acc |> list.length() |> int.subtract(1)
          let acc = acc |> list.take(acc_length) |> list.append([new_list])
          acc
        }
        _ -> acc |> list.append([item])
      }
    }) 
}

fn calc(columns: List(List(String))) -> Int {
  calc_loop(columns, 0)
}

fn calc_loop(columns: List(List(String)), total: Int) -> Int {
  case columns {
    [] -> total
    [first, ..rest] -> {
      let operator = first |> list.last() |> result.unwrap("")
      let number_count = first |> list.length |> int.subtract(1)
      let numbers =
        first
        |> list.take(number_count)
        |> list.map(fn(x) { result.unwrap(int.parse(x), 0) })
      let sum = case operator {
        "+" -> numbers |> list.fold(0, int.add)
        "*" -> numbers |> list.fold(1, int.multiply)
        _ -> 0
      }
      calc_loop(rest, total + sum)
    }
  }
}

fn get_columns(file: String, reg_exp: String) -> List(List(String)) {
  let lines =
    file
    |> string.split("\n")
  let options = regexp.Options(case_insensitive: False, multi_line: True)
  let assert Ok(regexp_first) = regexp.compile(reg_exp, options)
  let rows =
    lines
    |> list.fold([[]], fn(acc, line) {
      let data =
        regexp.scan(regexp_first, line)
        |> list.map(fn(m) { m.content })
      acc |> list.append([data])
    })
  rows |> list.drop(1) |> list.transpose
}