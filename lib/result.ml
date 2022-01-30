include Stdlib.Result

module Let = struct
  let ( let* ) = bind
  let ( let+ ) x f = map f x
end
