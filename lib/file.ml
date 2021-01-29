open Bos_setup

type t =
  { path : Fpath.t
  ; content : string
  }

let write : t -> (unit, Rresult.R.msg) result =
 fun { path; content } -> Bos.OS.File.write path content
