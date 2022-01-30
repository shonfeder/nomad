module Kind = struct
  type t =
    | Library
    | Binary

  let to_string = function
    | Library -> "library"
    | Binary -> "executable"
end
