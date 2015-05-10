(* Practice with Lazy Programming *)

exception TODO

(* suspended comuptation: *)
type 'a susp = Susp of (unit -> 'a)

(* force: 'a susp -> 'a *)
let force (Susp f) = f ()

(* stream : *)
type 'a str = {hd: 'a  ; tl : ('a str) susp}

let rec ones = {hd = 1 ; tl = Susp (fun () -> ones)}

(* val numsFrom : int -> int str *)
let rec numsFrom n = 
{hd = n ; 
 tl = Susp (fun () -> numsFrom (n+1))}

let nats = numsFrom 0

(* ---------------------------------------------------- *)
(* Inspect a stream up to n elements 
   val take_str : int -> 'a str -> 'a list
*)
let rec take_str n s = match n with 
  | 0 -> []
  | n -> s.hd :: take_str (n-1) (force s.tl)

(* ---------------------------------------------------- *)
(* smap: ('a -> 'b) -> 'a str -> 'b str *)
let rec smap f s = 
{ hd = f (s.hd) ; 
  tl = Susp (fun () -> smap f (force s.tl))
}

(* 1. Write a lazy stream of church numerals beginning
   from 0 and the corresponding function. For example, the 
   head of any lazy_church stream should be the identity
   function and forcing the tail 3 times should yield 
   a function similar to f(f(f x))).
   val lazy_church : ('a -> 'a) -> ('a -> 'a) str = <fun> 
*)

let lazy_church f = raise TODO

(* 2. Write a map function for the given lazy tree type.
   The map function you write has to be lazy! In other words,
   your function should not compute the mapping for a node
   until it is forced.
   val l_tree_map : ('a -> 'b) -> 'a lazy_tree -> 'b lazy_tree = <fun> *)

(* a lazy tree consists of a node 'a and a list of children.
   Either a node has no children or it has at least one,
   represented by a list. *)
type 'a lazy_tree = {nd: 'a ; ch: ('a fin_tree) susp } 
and 'a fin_tree = Empty | NonEmpty of 'a lazy_tree list

let rec l_tree_map f t = raise TODO
and l_tree_map' f t = raise TODO

(* 3. Write a tree traversal function that explores the tree 
   in DFS order and outputs a list of the nodes in that order.
   val l_tree_trav : 'a lazy_tree -> 'a list = <fun> *)

(* I found the standard list libararies very helpful here *)

let rec l_tree_trav t = raise TODO
and l_tree_trav' t = raise TODO

(* 4. LAZYPROGCEPTION! Rewrite the function from 3. such that
   the list you are outputting is now a lazy list i.e. you traverse
   the tree in the same manner but only when the tail is forced. 
   val inception : 'a lazy_tree -> 'a lazy_list = <fun> *)

type 'a lazy_list = {lhd: 'a ; ltl : ('a fin_list) susp} 
and 'a fin_list = None | Some of 'a lazy_list

let inception t = raise TODO

;;

(* 
val test1a : float = 10.
val test1b : float = 10.
val test2a : int = 10
val test3a : int list =
  [10; 20; 40; 80; 80; 40; 80; 80; 20; 40; 80; 80; 40; 80; 80]
val test4a : int list =
  [10; 20; 40; 80; 80; 40; 80; 80; 20; 40; 80; 80; 40; 80; 80]
*) 

let test1a = 
  let bojack = lazy_church (fun x -> 2.0 *. x)
  in 
(force (force (force bojack.tl).tl).tl).hd 1.25
let test1b =
  let diane = lazy_church (fun x -> 2.0 *. x)
  in 
diane.hd 10.0
let test2a =
  let rec rick n = 
    { nd = n ;
      ch = Susp(fun() -> if n < 42 then NonEmpty [rick (n+1);rick (n+1)] else Empty)
    }
  in
  let morty = l_tree_map (fun x -> 2 * x) (rick 1)
  and gib_ch f = match f with NonEmpty c -> c | _ -> raise TODO
  in
(List.hd(gib_ch(
  force(List.hd(gib_ch(
    force(List.hd(gib_ch(
      force(List.hd(gib_ch(
        force morty.ch
      ))).ch
    ))).ch
  ))).ch
))).nd
let test3a = 
  let rec finn n = 
    { nd = n ;
      ch = Susp(fun() -> if n < 80 then NonEmpty [finn (2 * n);finn (2 * n)] else Empty)
    }
  in
l_tree_trav (finn 10)
let test4a = 
  let rec jake n = 
    { nd = n ;
      ch = Susp(fun() -> if n < 80 then NonEmpty [jake(2*n);jake(2*n)] else Empty)
    }
  and take n s = match n with 
    | 0 -> []
    | n -> s.lhd :: take' (n-1) (force s.ltl)
  and take' n s = match s with 
    | None -> [] 
    | Some s -> take n s
  in
take 20 (inception (jake 10))
