(* Practice with continuations *)

(* 1. Write List.fold_left recursively *)

let rec r_fold_left f e l = match l with
  | []    -> e
  | x::xs -> r_fold_left f (f e x) xs

(* 2. Write List.fold_left tail-recursively using continuations *)

let c_fold_left f e l = 
  let rec inner f e l c =
    match l with
      | []    -> c e
      | x::xs -> inner f e xs ( fun y -> f ( c y ) x )
  in
inner f e l (fun x -> x)

(* 3. Write List.map tail-recursively using continuations *)

let c_map f l = 
  let rec inner f l c =
    match l with
      | []    -> c []
      | x::xs -> inner f xs ( fun y -> c ( (f x)::y ) )
  in
inner f l (fun x -> x)

(* 4. Write a Church numeral function that takes a function 
   and an integer as parameters and outputs the
   corresponding Church numeral function for the given 
   integer and function using continuations.
   val church : ('a -> 'a) -> int -> 'a -> 'a = <fun> 
*)

let church f n =
  let rec inner f n c =
    if n <= 0 then
      c (fun x -> x)
    else 
      inner f (n-1) ( fun y -> c (fun x -> f (y x)) )
  in
inner f n (fun x -> x)

(* 
val test1a : int = 10
val test1b : int = 10
val test1c : string = "1234"
val test2a : int = 10
val test2b : int = 10
val test3a : int list list = [[1; 10]; [2; 10]; [3; 10]; [4; 10]]
val test3b : int list list = []
val test4a : int = 10
val test4b : int = 10
 *)

let test1a = r_fold_left (fun x y -> x + y) 0 [1;2;3;4]
let test1b = r_fold_left (fun x y -> x + y) 10 []
let test1c = r_fold_left (fun x y -> x ^ y) "" ["1";"2";"3";"4"]
let test2a = c_fold_left (fun x y -> x + y) 0 [1;2;3;4]
let test2b = c_fold_left (fun x y -> x + y) 10 []
let test3a = c_map (fun x -> [x;10]) [1;2;3;4]
let test3b = c_map (fun x -> [x;10]) []
let test4a = (church (fun x -> x + 1) 10) 0
let test4b = (church (fun x -> x + 1) 0) 10
