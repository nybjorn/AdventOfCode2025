import argv
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/result
import gleam/string
import gleam/time/duration
import gleam/time/timestamp
import simplifile

pub fn main() -> Nil {
  io.println("Hello from gleamy_day_5!")
  //let filepath = "./sample.txt"
  let filepath = "./part1.txt"
  let start_time = timestamp.system_time()
  let assert Ok(file) = simplifile.read(from: filepath)
  let #(fresh_ingredients, ingredients) = process_file(file)

  case argv.load().arguments {
    ["part1"] -> {
      available_fresh(fresh_ingredients, ingredients)
      |> echo
      "1️⃣  " |> io.print
    }

    ["part2"] -> {
      echo all_available_fresh(fresh_ingredients)
      "2 " |> io.print
    }
    _ -> {
      io.println("Usage:  part1 | part2")
    }
  }
  let duration = timestamp.difference(start_time, timestamp.system_time())
  "🌟 " |> io.print
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
  Nil
}

fn process_file(file: String) -> #(List(List(Int)), List(Int)) {
  let lines = file |> string.split("\n")
  lines
  |> list.fold(#([], []), fn(acc, row) {
    let lists = separate_lists(row)
    let fresh = case lists.0 {
      [] -> acc.0
      _ -> acc.0 |> list.append([lists.0])
    }
    let orderd = acc.1 |> list.append(lists.1)
    #(fresh, orderd)
  })
}

fn separate_lists(row_string: String) -> #(List(Int), List(Int)) {
  case row_string |> string.contains("-") {
    False -> {
      case row_string |> string.compare("") {
        order.Eq -> #([], [])
        _ -> {
          let order_item = int.parse(row_string) |> result.unwrap(0)
          #([], [order_item])
        }
      }
    }
    _ -> {
      let list = row_string |> string.split("-")
      let start = list.first(list) |> result.unwrap("")
      let end = list.first(list.drop(list, 1)) |> result.unwrap("")
      let start_int = int.parse(start) |> result.unwrap(0)
      let end_int = int.parse(end) |> result.unwrap(0)
      #([start_int, end_int], [])
    }
  }
}

fn available_fresh(
  fresh_ingredients: List(List(Int)),
  ordered_ingredients: List(Int),
) -> Int {
  let sum =
    ordered_ingredients
    |> list.fold(0, fn(acc, item) {
      case in_fresh(item, fresh_ingredients) {
        True -> acc + 1
        False -> acc
      }
    })
  sum
}

fn all_available_fresh(fresh_ingredients: List(List(Int))) -> Int {
  let merged =
    fresh_ingredients
    |> list.sort(fn(lista, listb) { sort_id_lists(lista, listb) })
    |> merge_ingredients
  merged
  |> list.fold(0, fn(acc, item) {
    let min = list.first(item) |> result.unwrap(0)
    let max = list.last(item) |> result.unwrap(0)
    acc + max - min + 1
  })
}

fn merge_ingredients(fresh_ingredients: List(List(Int))) -> List(List(Int)) {
  merge_ingredients_loop(fresh_ingredients |> list.drop(1), [
    list.first(fresh_ingredients) |> result.unwrap([]),
  ])
}

fn merge_ingredients_loop(
  fresh_ingredients: List(List(Int)),
  merged_ingredients: List(List(Int)),
) -> List(List(Int)) {
  case fresh_ingredients {
    [] -> merged_ingredients
    [first_fresh, ..the_rest_of_fresh] -> {
      let last_merged = list.last(merged_ingredients) |> result.unwrap([])
      let max_first_fresh = list.last(last_merged) |> result.unwrap(0)
      let min_first_of_the_rest = list.first(first_fresh) |> result.unwrap(0)
      let max_first_of_the_rest = list.last(first_fresh) |> result.unwrap(0)
      case max_first_fresh < min_first_of_the_rest {
        True -> {
          let merged = merged_ingredients |> list.append([first_fresh])
          merge_ingredients_loop(the_rest_of_fresh, merged)
        }
        False -> {
          let new_max = int.max(max_first_fresh, max_first_of_the_rest)
          let new_merged_first = [
            list.first(last_merged) |> result.unwrap(0),
            new_max,
          ]
          let merged_ingredients =
            merged_ingredients
            |> list.take(list.length(merged_ingredients) - 1)
            |> list.append([new_merged_first])
          merge_ingredients_loop(the_rest_of_fresh, merged_ingredients)
        }
      }
    }
  }
}

fn sort_id_lists(lista: List(Int), listb: List(Int)) -> order.Order {
  let min_a = list.first(lista) |> result.unwrap(0)
  let min_b = list.first(listb) |> result.unwrap(0)
  int.compare(min_a, min_b)
}

fn in_fresh(item: Int, fresh_ingredients: List(List(Int))) -> Bool {
  fresh_ingredients
  |> list.any(fn(fresh_list) {
    let min = list.first(fresh_list) |> result.unwrap(0)
    let max = list.last(fresh_list) |> result.unwrap(0)
    item >= min && item <= max
  })
}
