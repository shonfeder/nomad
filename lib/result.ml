include Stdlib.Result

module Let = struct
  let ( let* ) = bind
  let ( let+ ) x f = map f x
end

let of_rresult : ('a, Rresult.R.msg) t -> ('a, string) t =
 fun x -> Rresult.R.reword_error (fun (`Msg m) -> m) x
