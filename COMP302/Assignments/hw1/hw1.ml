(* HOMEWORK 1 : COMP 302 Fall 2014 
   
   PLEASE NOTE:  

   * All code files must be submitted electronically
     BEFORE class on 18 Sep, 2014

  *  The submitted file name must be hw1.ml 

  *  Your program must type-check and run usig 
     OCaml of at least OCaml 4.0

  * Remove all "raise NotImplemented" with your solutions
*)

exception NotImplemented
exception Domain

(* ------------------------------------------------------------*)
(* QUESTION 2 : WARM-UP                                        *)
(* ------------------------------------------------------------*)
(* Q2 Computing the square root                                *)

let square_root a =  
  let rec findroot x acc = 
    let a_diff = abs_float ( x -. ( a /. x +. x ) /. 2.0 )
    in 
    if a_diff < acc then 
      ( a /. x +. x ) /. 2.0
    else 
      findroot ( ( a /. x +. x ) /. 2.0 ) acc
  in
  findroot 1.0 epsilon_float


(* ------------------------------------------------------------*)
(* QUESTION 3 : House of Cards                                 *)
(* ------------------------------------------------------------*)

type suit = Clubs | Spades | Hearts | Diamonds

type rank =  Six | Seven | Eight | Nine | Ten | 
             Jack | Queen | King | Ace

type card = rank * suit

type hand = Empty | Hand of card * hand

(* dom : suit -> suit -> bool

   dom(s1,s2) = true iff suit s1 beats or is equal to suit s2
                relative to the ordering S > H > D > C         
   Invariants: none
   Effects: none
*)

let dom s1 s2 = match s1, s2 with
  | Spades, _        -> true
  | Hearts, Diamonds -> true
  | Hearts, Clubs    -> true
  | Diamonds, Clubs  -> true
  | s1, s2           -> s1 = s2


let dom_rank r1 r2 = match r1, r2 with
  | Ace, _     -> true
  | King, r2   -> not ( r2 = Ace )
  | Queen, r2  -> not ( r2 = Ace || r2 = King )
  | Jack, r2   -> not ( r2 = Ace || r2 = King || r2 = Queen )
  | Ten, r2    -> r2 = Nine || r2 = Eight || r2 = Seven || r2 = Six
  | Nine, r2   -> r2 = Eight || r2 = Seven || r2 = Six
  | Eight, r2  -> r2 = Seven || r2 = Six
  | Seven, Six -> true
  | s1, s2     -> s1 = s2

let greater (r1, s1) (r2, s2) = 
dom s1 s2 && dom_rank r1 r2

let rec insert (c : card) h = match c, h with
  | c , Empty -> Hand ( c , Empty )
  | ( ( r1 , s1 ), Hand( (r2, s2), next) ) -> if greater( r1, s1 )( r2, s2 ) then
                                     Hand( c, Hand( (r2, s2), next) ) else
                                            Hand( (r2, s2), insert c next)
                                     

let ins_sort h = 
  let rec innersort (unsorted, sorted) = match unsorted, sorted with
    | Empty, sorted -> Empty, sorted
    | Hand (c, nextunsorted), sorted -> innersort (nextunsorted, insert c sorted)
  in 
    match innersort (h, Empty) with
      | (l1,l2) -> l2
 

(* --------------------------------------------------------------------*)
(* QUESTION 3 Sparse representation of binary numbers                  *)
(* ------------------------------------------------------------------- *)

type nat = int list (* increasing list of weights, each a power of two *)

(* For example: 

5  = [1,4]
13 = [1,4,8]

*)

(* ------------------------------------------------------------------- *)
(* Q4.1 : Incrementing a binary number (10 points)                     *)
(* ------------------------------------------------------------------- *)

let inc (ws:nat) = 
  let rec innerinc (exp, list) = match exp, list with
    | exp, [] -> ([exp]:nat)
    | exp, front::bottom -> if front != exp then 
        exp::front::bottom else
        innerinc (exp * 2, bottom)         
  in 
    innerinc (1, ws)


(* ------------------------------------------------------------------- *)
(* Q4.2 : Decrementing a sparse binary number  (10 points)             *)
(* ------------------------------------------------------------------- *)

let dec (ws:nat) = 
  let rec innerdec (top) = match top with
    | 0 -> []
    | top -> innerdec ( top / 2 )@[top]
  in 
    match ws with
      | [] -> ([]:nat)
      | top::bottom -> innerdec (top / 2) @ bottom

(* ------------------------------------------------------------------- *)
(* Q4.3 : Adding sparse binary numbers  (10 points)                    *)
(* ------------------------------------------------------------------- *)

let add (m:nat) (n:nat)  = 
  let rec inneradd (l1, l2, carry, result, exp) = 
    match l1, l2, carry, exp with 
    | [] , [] , false , _ -> (result:nat)
    | [] , [] , true , exp -> (result@[exp]:nat)
    | [] , x::bottom , carry , exp | x::bottom, [] , carry , exp -> 
        ( if x = exp && carry = true then
            inneradd ( [] , bottom , true , result , (exp * 2) )
          else if x = exp && carry = false then
            inneradd ( [] , bottom , false , result@[exp] , (exp * 2) )
          else if x <> exp && carry = true then
            inneradd ( [] , x::bottom , false , result@[exp] , (exp * 2) )
          else 
            inneradd ( [] , x::bottom , false , result , (exp * 2) ) )
    | x1::bottom1, x2::bottom2, true, exp -> 
        ( if x1 = exp && x2 = exp then
            inneradd ( bottom1 , bottom2 , true , result@[exp] , (exp * 2) )
          else if x1 = exp && x2 <> exp then
            inneradd ( bottom1 , x2::bottom2 , true , result , (exp * 2) )
          else if x1 <> exp && x2 = exp then
            inneradd ( x1::bottom1 , bottom2 , true , result , (exp * 2) )
          else 
            inneradd ( x1::bottom1 , x2::bottom2 , false , result@[exp] , (exp * 2) ) )
    | x1::bottom1, x2::bottom2, false, exp ->
        ( if x1 = exp && x2 = exp then
            inneradd ( bottom1 , bottom2 , true , result , (exp * 2) )
          else if x1 = exp && x2 <> exp then
            inneradd ( bottom1 , x2::bottom2 , false , result@[exp] , (exp * 2) )
          else if x1 <> exp && x2 = exp then 
            inneradd ( x1::bottom1 , bottom2 , false , result@[exp] , (exp * 2) )
          else 
            inneradd ( x1::bottom1 , x2::bottom2 , false , result , (exp * 2) ) )
  in
    inneradd (m, n, false, [], 1)

(* ------------------------------------------------------------------- *)
(* Q4.3 : Converting to integer - tail recursively  (10 points)        *)
(* ------------------------------------------------------------------- *)

let sbinToInt (n:nat) = 
  let rec innerToInt (binary, acc) = 
    match binary, acc with
    | [], acc -> acc
    | top::bottom, acc -> innerToInt (bottom, acc+top)    
  in 
    innerToInt (n, 0)
    
(* --------------------------------------------------------------------*)
(* QUESTION 5 Negation Normal Form                                     *)
(* ------------------------------------------------------------------- *)

type prop = 
  | Atom of string
  | Neg of prop
  | Conj of prop * prop
  | Disj of prop * prop
  | Impl of prop * prop


let rec nnf p = 
  match p with
   | Neg ( Neg ( propA ) ) -> nnf ( propA )
   | Neg ( Conj ( propA, propB ) ) -> nnf ( Disj ( Neg ( propA ) , Neg ( propB ) ) )
   | Neg ( Disj ( propA, propB ) ) -> nnf ( Conj ( Neg ( propA ) , Neg ( propB ) ) )
   | Impl ( propA, propB ) -> nnf ( Disj ( Neg ( propA ) , propB ) )
   | Neg ( propA ) -> Neg ( nnf ( propA ) )
   | Conj ( propA, propB ) -> Conj ( nnf ( propA ), nnf ( propB ) )
   | Disj ( propA, propB ) -> Disj ( nnf ( propA ), nnf ( propB ) )
   | p -> p

let f1 = Neg (Conj (Atom "p", Disj (Atom "q", Atom "r")))
let f2 = Neg (Conj (Neg (Atom "p"), Disj (Atom "q", Atom "r")))
let f3 = Disj (Neg(Conj (Atom "q", Atom "p")), Neg(Neg (Atom "p")))
