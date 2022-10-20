(** Auxiliary functions *)

(** [count_matches pattern string] is the number of times [pattern] appears
    in [string] (non-overlapping count).

    XXX StackOverlow if given [""] for the pattern *)
let count_matches : string -> string -> int =
 fun pattern string ->
  let pattern_len = String.length pattern in
  let regexp = Str.regexp_string pattern in
  if pattern_len > String.length string then
    0
  else
    let rec count pos acc =
      try
        let pos = Str.search_forward regexp string pos in
        count (pos + pattern_len) (succ acc)
      with
      | Not_found -> acc
    in
    count 0 0
