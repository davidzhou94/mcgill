(* Practice with typing *)

(* identify each of the following types *)

let x1 = 1
let x2 = 1.0
let x3 = true
let f1 a b = a b
let f2 a b = a ( a b )
let f3 a b c = if a b then a b else c b
let f4 x y z = if (x y = z) then x z > 10 else x y < 10;;

(* identify what the following evaluate to *)

List.map (fun x -> (10-x, true)) [1;2;3;4];;

List.fold_left (fun x y -> x - y) 0 [1;2;3;4];;

List.fold_right (fun x y -> x - y) [10;10;10;10;10] 0;;
