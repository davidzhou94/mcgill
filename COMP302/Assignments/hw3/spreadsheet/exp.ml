 module Spreadsheet : SPREADSHEET = 
  struct 
    (* Spreadsheet 

   We model a column in a spreadsheet as a list and a spreadsheet as a list of columns.
   *)
  exception NotImplemented

  (* In the spreadsheet we store arithmetic expressions. The simplest 
   arithmetic expression is a number; more complex arithmetic
   expressions can be formed using the constructors Plus and Times.

   Each node in the abstract syntax tree for expressions stores its
   value. The value of a number is simply an integer. The value of a 
   Plus-expression is the sum of the values of the two subtrees; the
   value of a Times-expression is the product of the values of the
   values of the two subtrees.

   *)

  type exp = 
    | Num of int ref
    | Plus of int ref * exp * exp
    | Times of int ref * exp * exp


  type spreadsheet = exp list list
  type column = exp list

  (* Helper function: get the value at a node in the abstract syntax
   tree of an arithmetic expression *)
  let get_value e = match e with
    | Num r -> !r 
    | Plus (r, _, _ ) -> !r
    | Times (r, _, _ ) -> !r 

  (* Create a number expression *)
  let num x = Num x


  let initialize m = List.map (fun c -> List.map (fun x -> Num x) c) m

  (* ————————————————————–—————————————————————————————————————————————– *)
  (* QUESTION 4.1 *)
  (* Helper function: given two expressions, we add or multiply 
   them     *)
  (* ————————————————————–—————————————————————————————————————————————– *)
  let add x y = Plus( ref ((get_value x) + (get_value y)), x, y )
  let mult x y = Times( ref ((get_value x) * (get_value y)), x, y )


  (* ————————————————————–—————————————————————————————————————————————– *)
  (* QUESTION 4.2                                                        *)
  (* compute_column m f = c

   Given a spreadsheet m and a function f, compute the i-th value in  
   the result column c by using the i-th value from each column in m.
 
   Example: 
   m = [ [a1 ; a2 ; a3 ; a4] ; 
         [b1 ; b2 ; b3 ; b4] ; 
         [c1 ; c2 ; c3 ; c4] ]

  To compute the 2nd value in the new column, we call f with
  [a2 ; b2 ; c2] 

   Generic type of compute_column: 
     'a list list -> ('a list -> 'b) -> 'b list  

   If it helps, you can think of the specific case where we have a 
   spreadsheet containing expressions, i.e. 
   compute_column: exp list list -> (exp list -> exp) -> exp list

   Use List.map to your advantage!

   Carefully design the condition when you stop.
   *)
  (* ————————————————————–—————————————————————————————————————————————– *)

  exception Error of string

  let inner_tran l = match l with
    | x::xs -> x
    | _ -> raise (Error "Input spreadsheet has columns of different length")
  let inner_tran2 l = match l with
    | x::xs -> xs
    | _ -> raise (Error "Input spreadsheet has columns of different length")

  let rec transpose array = match array with
    | [] -> []
    | (x::xs)::ls -> (x::(List.map inner_tran ls))::transpose(xs::(List.map inner_tran2 ls))
    | []::_ -> []

  let rec compute_column m f = List.map f (transpose m)

  let add_column m c = m@[c]
  (* ————————————————————–—————————————————————————————————————————————– *)
  (* QUESTION 4.3 *)
  (* Implement a function update  which given an expression will re-
   compute the values stored at each node. This function will be used
   after we have updated a given number.

   update  : exp -> unit 

   *)
  (* ————————————————————–—————————————————————————————————————————————– *)
  let update_cell (loc, v) = (loc := v)

  let rec update e = match e with
    | Num(n) -> update_cell (n, !n)
    | Plus(n,l,r) -> (
        update l;
        update r;
        update_cell (n, get_value (add l r) ) )
    | Times(n,l,r) -> ( 
        update l;
        update r;
        update_cell (n, get_value (mult l r) ) )

  (* Fully update a whole spreadsheet *)
  let update_exp e = update e 
  let update_column c = List.fold_left (fun _ e -> update e) () c
  let update_sheet m = List.fold_left  (fun _ c -> update_column c) () m  
				
  (* EXTRA FUN:
   Our implementation traverses the whole expression and even worse
   the whole spreadsheet, if one number cell is being updated.

   If you are looking for a nice programming problem, think
   about how to update only those values which are parent nodes to the
   Number being updated. You might need to choose a different
   representation for expressions.

 *)
(* ————————————————————–—————————————————————————————————————————————– *)

  let m = [ [ Num (ref 0) ; Num (ref 1); Num (ref 2)] ; 
            [ Num (ref 4) ; Num (ref 7) ; Num (ref 9)] ; 
            [ Num (ref 2); Num (ref 3); Num (ref 10)] ]

end 
