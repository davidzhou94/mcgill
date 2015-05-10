module type SERIES = 
sig
  val ones            : int Stream.str  
  val numsFrom        : int -> int Stream.str
  val fibonacci_series: int Stream.str
  val hamming_series  : int Stream.str 
end ;;


module Series : SERIES = 
struct

  open Stream 

(* stream of ones *)
  let rec ones = {hd = 1 ; tl = Susp (fun () -> ones)} ;;

(* series of natural numbers starting from n *)
let rec numsFrom n = 
  {hd = n ; 
   tl = Susp (fun () -> numsFrom (n+1))}

(* series of natural numbers starting from 0 *)
  let nats = numsFrom 0 

(* ------------------------------------------------------- *)
(* Let "fibs()" represent the infinite sequence of Fibonacci numbers. Then,
   schematically, we can write:

      fibs() = 0 1 add(fibs(), tl(fibs()))

   It is almost what we can write in OCaml using observations.

Construct a stream of the fibonacci numbers -

ROUGHLY
  a      b        Fib stream
  0...   1...     0, ...
  1...   1...     0, 1 ...
  1...   2...     0, 1, 1, ...
  2...   3...     0, 1, 1, 2, ....
  3...   5...     0, 1, 1, 2, 3, ...
  5...   8...     0, 1, 1, 2, 3, 5, ...
  8...  13...     0, 1, 1, 2, 3, 5, 8 ...

*)

let rec fibs = 
{hd = 0 ; 
  tl = Susp (fun () -> fibs') }
and fibs' = 
{hd = 1 ;
 tl = Susp (fun () -> add fibs fibs')
}

let fibonacci_series = fibs 

(* Hamming series *) 
let factor x s = map (fun n -> x * n) s

let rec all_the_hams = 
  { hd = 1 ;
    tl = Susp ( fun () -> 
                  ( merge (factor 2 all_the_hams)
                  ( merge (factor 3 all_the_hams)
                          (factor 5 all_the_hams) ) )
              )
  }

let rec filter_out_duplicates s =
  { hd = s.hd ;
    tl = Susp ( fun () -> 
                  filter_out_duplicates ( filter (fun x -> not(x = s.hd)) (force s.tl) )
              )
  }

let hamming_series = filter_out_duplicates all_the_hams

end;;
