module type STREAM = 
sig
  exception TODO
  type 'a susp = Susp of (unit -> 'a)
  val delay : (unit -> 'a) -> 'a susp 
  val force : 'a susp -> 'a 

  type 'a str = { hd : 'a; tl : 'a str susp; }

  val take  : int -> 'a str -> 'a list 
  val map   : ('a -> 'b) -> 'a str -> 'b str 
  val filter: ('a -> bool) -> 'a str -> 'a str 
  val add   : int str -> int str -> int str 
  val merge : 'a str -> 'a str -> 'a str 
end;;

module Stream : STREAM = 
struct

  exception TODO

  (* Suspended computation : we can suspend computation
     by wrapping it in a closure. *)
  type 'a susp = Susp of (unit -> 'a)

  (* delay *)
  let delay f = Susp f

  (* force: *)
  let force (Susp f) = f ()

  type 'a str = {hd: 'a  ; tl : ('a str) susp} 

 
  let rec map f s = 
    { hd = f (s.hd) ; 
      tl = Susp (fun () -> map f (force s.tl))
    }

  (* Inspect a stream up to n elements *)
  let rec take n s = match n with 
    | 0 -> []
    | n -> s.hd :: take (n-1) (force s.tl)


  let rec filter p s = 
    let h,t = find_hd p s in 
    {hd = h;
     tl = Susp (fun () -> filter p (force t))
    }
  and find_hd p s = 
    if  p (s.hd) then (s.hd, s.tl)
    else find_hd p (force s.tl)
      
(* Note: find_hd is NOT productive! Hence, filter is not productive.
*)

  let rec add s1 s2 = 
    {hd = s1.hd + s2.hd ; 
     tl = Susp (fun () -> add (force s1.tl) (force s2.tl)) 
    }

      
  let rec merge s1 s2 = 
    { hd = ( if (s1.hd > s2.hd) then 
               s2.hd else 
                 s1.hd ) ;
      tl = Susp (fun () -> 
                   if (s1.hd > s2.hd) then 
                     (merge s1 (force s2.tl)) else 
                       (merge (force s1.tl) s2) )
    }

end ;;

let factor x s = Stream.map (fun n -> x * n) s

let rec all_the_hams = 
  { Stream.hd = 1 ;
    Stream.tl = Stream.Susp 
    ( fun () -> 
          ( Stream.merge (factor 2 all_the_hams)
          ( Stream.merge (factor 3 all_the_hams)
                         (factor 5 all_the_hams) ) )
    )
  }

let hamming_series =
  let rec inner_ham s =
    { Stream.hd = s.Stream.hd ;
      Stream.tl = Stream.Susp ( 
        fun () -> inner_ham ( Stream.filter (fun x -> not(x = s.Stream.hd)) (Stream.force s.Stream.tl) )
      )
    }
  in
inner_ham all_the_hams


