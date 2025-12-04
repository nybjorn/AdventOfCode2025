import argv
import gleam/dict
import gleam/io
import gleam/list
import gleam/order
import gleam/string
import gleam/option
import simplifile

pub fn main() -> Nil {
  io.println("Hello from gleamy_day_4!")
  let filepath = "./sample.txt"
 //let filepath = "./part1.txt"
  let assert Ok(file) = simplifile.read(from: filepath)
  let roll_map = make_a_map(file)
  case argv.load().arguments {
    ["part1"] -> {
      part1(roll_map)
      |> echo
    }
    ["part2"] -> {
      part2(roll_map)
      |> echo
    }
    _ -> {
      io.println("Usage:  part1 | part2")
      -1
    }
  }
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

fn part1(map: dict.Dict(#(Int, Int), String)) -> Int {
  map |> dict.to_list()
  |> list.filter(fn(x) { x.1 == "@" })
  |> list.map(fn(x) { get_number_of_rolls(x.0, map) }) |> list.count(fn(x) { x<4})
}

fn part2(map: dict.Dict(#(Int, Int), String)) -> Int {
  part2_loop(map,0)
}

fn part2_loop(map: dict.Dict(#(Int, Int), String), total_removed: Int ) -> Int {
  let can_be_removed = map |> dict.to_list()
  |> list.filter(fn(x) { x.1 == "@" })
  |> list.filter(fn(x) { get_number_of_rolls(x.0, map) < 4  })

  case list.length(can_be_removed) {
    0 -> total_removed
    x -> {
      let new_map = can_be_removed |> list.fold(map, fn(acc, item) {
        acc |> dict.upsert(item.0, fn(x) { case x {
          option.Some(_) -> "x" 
          _ -> "."
        }  })
      })
      part2_loop(new_map, total_removed +x)
    }
  }

}


fn get_number_of_rolls(
  coordinate: #(Int, Int),
  map: dict.Dict(#(Int, Int), String),
) -> Int {
  let #(row, col) = coordinate
  let positions_to_check = [
  #(row - 1, col - 1),
  #(row - 1, col),
  #(row - 1, col + 1),
  #(row, col - 1),
  #(row, col + 1),
  #(row + 1, col - 1),
  #(row + 1, col),
  #(row + 1, col + 1),
  ]

  positions_to_check
  |> list.map(fn(pos) { get_number_of_rolls_at(pos, map) })
  |> list.count(fn(x) { x == 1 })
}

fn get_number_of_rolls_at(
  coordinat: #(Int, Int),
  map: dict.Dict(#(Int, Int), String),
) -> Int {
  case dict.get(map, coordinat) {
    Ok(value) -> {
      case string.compare("@", value) {
        order.Eq -> 1
        _ -> 0
      }
    }
    _ -> 0
  }
}