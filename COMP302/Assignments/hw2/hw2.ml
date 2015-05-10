(* HOMEWORK 2 : COMP 302 Fall 2014 
  
   NOTE:  

   All code files must be submitted electronically
   before class on Oct 2.

  The submitted file name must be hw2.ml 

  Your program must type-check using OCaml.

*)

exception NotImplemented

(* -------------------------------------------------------------*)
(* QUESTION 2 :  [60 points]                                    *) 
(* -------------------------------------------------------------*)

type 'a tree = Empty | Node of 'a * 'a tree * 'a tree

(* insert:  'a * 'b -> ('a * 'b) tree -> ('a * 'b) tree
   
   insert (x,d) T = T'  where (x,d) has been inserted into T
   and any previous occurrences of (x,d') in T have been
   overwritten
  
*)

let rec insert ((x,d) as e) t = match t with 
  | Empty               -> Node(e, Empty, Empty)
  | Node ((y,d'), l, r) ->  
      if x = y then Node(e, l, r) 
      else 
	(if x < y then Node((y,d'), insert e l, r)
	 else 
	   Node((y,d'), l, insert e r))



(* -------------------------------------------------------------*)
(* QUESTION 2.1 : [10 points]                                   *) 
(* -------------------------------------------------------------*)
(* Implement a function create_tree which when given a list
   of data and key entries creates a binary tree storing all the entries, i.e.
   we repeatedly insert the entries into an empty tree.   

   create_tree: ('a * 'b) list -> ('a * 'b) tree

   Use the higher-order function List.fold_left 
 *)  

let create_tree l = 
  let invert_insert t e = insert e t
  in 
match l with
  | [] -> Empty
  | _ -> List.fold_left invert_insert Empty l

(* Use the function repeat to insert a list of elements into an empty 
   tree thereby creating a binary tree.
*)

(* 
let t = create_tree [(10,"bob"); (5, "alice"); (3,"daniel"); (7, "chelsea") ; (15,"alex"); (11,"emile")]

t should be of the following form:

Node ((10, "bob"),
 Node ((5, "alice"), Node ((3, "daniel"), Empty, Empty),
  Node ((7, "chelsea"), Empty, Empty)),
 Node ((15, "alex"), Node ((11, "emile"), Empty, Empty), Empty))

 *) 


(* -------------------------------------------------------------*)
(* QUESTION 2.2 : [10 points]                                   *) 
(* -------------------------------------------------------------*)
(* Implement a function tree_map 
   which when given a function f and a tree applies f to all
   the entries in the tree. 
 *)

let rec tree_map f t = match t with
  | Empty -> Empty
  | Node (e, l, r) -> Node ( f (e), tree_map f l, tree_map f r)

(* -------------------------------------------------------------*)
(* QUESTION 2.3 : [5 points]                                   *) 
(* -------------------------------------------------------------*)
(* Delete all the data from a binary search tree which stores 
   entries as pairs consisting of key and data obtaining
   a tree of the same shape.                 
*)
(* delete_data: ('a * 'b) tree  -> 'a tree                      *)

let delete_data t = 
  let inner_delete_data e = match e with
    | (a, b) -> a
  in 
    tree_map inner_delete_data t

(* -------------------------------------------------------------*)
(* QUESTION 2.4 : [15 points]                                   *) 
(* -------------------------------------------------------------*)
(*  Intuitively, fold_right replaces every :: by f and nil
  by e in a list. The function tree_fold for binary trees is analogous to 
  fold_right. Given a tree, tree_fold replaces each leaf by some 
  value e and each node by the application of a 3-argument function  f 

  It has type:

  tree_fold: ('a * 'b * 'b -> 'b) -> 'b -> 'a tree -> 'b 

  Example: Given a tree 
  Node (x0, Node (x1, Empty, Empty), 
            Node (x2, Node (x3, Empty, Empty), Empty)) 

  the result will be 

  f(x0, f (x1, e, e), f (x2, f (x3, e, e), e))

  15 points
 *)

let rec tree_fold f e t = match t with
  | Empty -> e
  | Node (x, l, r) -> f (x, (tree_fold f e l), (tree_fold f e r))

(* -------------------------------------------------------------*)
(* QUESTION 2.5 : [20 points]                                   *) 
(* -------------------------------------------------------------*)
(* The tree_fold function allows us to express many programs which 
   traverse trees elegantly in one line.

  a) Re-implement the function size : 'a tree -> int which given a
   binary tree returns the number of nodes in the tree using tree_fold
   (5 points)

  b) Implement the function reflect : 'a tree -> int which given a
   binary tree swaps the left and the right child using tree_fold
   (5 points)

  c) Implement inorder: 'a tree -> 'a list which given a binary tree
   returns a list of all entries in order.
   (10 points)

 *)
let size tr = 
  let inner_size (a, b1, b2) = 1 + b1 + b2
  in 
tree_fold inner_size 0 tr

let reflect tr = 
  let inner_reflect (a, b1, b2) = Node (a, b2, b1)
  in 
tree_fold inner_reflect Empty tr

let inorder tr = 
  let inner_inorder (a, b1, b2) = b1@[a]@b2
  in 
tree_fold inner_inorder [] tr



(* -------------------------------------------------------------*)
(* QUESTION 3 :  [15 points]                                    *) 
(* -------------------------------------------------------------*)
(* Write a function pow_series: int -> int list -> (int -> int)
   which computes the power series. Given a constant c and a 
   list of coefficients a1 ... ak return a function :

   f(x) = a0 + a1*(x-c)^1 + a2*(x-c)^2 + ... + ak*(x-c)^k 

   Note that the function you return should be independently 
   meaningful, i.e. it should  contain only calls to pow, addition, 
   subtraction or multiplication,   but no other functions.

 *)

let rec pow x n = 
  if n <= 0 then 1
  else
    x * pow x (n-1) 

let pow_series c l = 
  let rec inner_pow_series f c l n = match l with
    | [] -> ( fun x -> f(x) )
    | top::bottom -> inner_pow_series (fun x -> f(x) + top * pow (x - c) n) c bottom (n+1)
  in 
inner_pow_series (fun x -> 0) c l 0


















