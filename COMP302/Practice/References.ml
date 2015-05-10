(* Practice for references *)

(* 1. Draw an evironment diagram for the following. 
   Look at your diagram, does f e !c return an output? 
   If so, what is it? *)

let a = ref 10
let b = ref 20
let c = ref a
let d = ref (2 * !a)
let _ = a := 20 ; b := 10
let e = ref (!b + !d)
let f x y = !x - !y;;

f e !c;;

(* 2. So OCaml doesn't do lists of arbitrary types but we can always
   make shit up that comes pretty close. Using the definition 
   of a shitty "type-independent" list below, write the append function. 
   val append : plist -> plist -> plist = <fun> *)

type plist = Empty | NonEmpty of cell
and cell = { hd : content ; mutable tl : plist ref }
and content = Int of int | Float of float | String of string | Bool of bool

let rec append l1 l2 =
  match l1, l2 with
    | Empty, Empty      -> Empty
    | NonEmpty c, Empty -> l1
    | Empty, NonEmpty c -> l2
    | NonEmpty c1, NonEmpty c2 -> append' c1 c2 ; l1
and append' c1 c2 =
  match !(c1.tl) with
    | Empty      -> (c1.tl := (NonEmpty(c2)) )
    | NonEmpty c -> append' c c2

(* 3. Now write the reversal function for the shitty polymorphic list.
   val reverse : plist -> plist = <fun> *)

let rec reverse l = 
  match l with
    | Empty -> Empty
    | NonEmpty c1 -> match !(c1.tl) with
        | Empty       -> l
        | NonEmpty c2 -> c1.tl := Empty ; NonEmpty(reverse' c1 c2)
and reverse' c1 c2 =
  match !(c2.tl) with
    | Empty      -> (c2.tl := (NonEmpty(c1)) ; c2 )
    | NonEmpty c -> (c2.tl := (NonEmpty(c1)) ; reverse' c2 c )

(* 
val test2a : plist =
  NonEmpty
   {hd = Int 4;
    tl =
     {contents =
       NonEmpty
        {hd = Float 20.;
         tl =
          {contents =
            NonEmpty
             {hd = String "scheiss";
              tl =
               {contents =
                 NonEmpty
                  {hd = String "pankow";
                   tl =
                    {contents =
                      NonEmpty
                       {hd = Int 37;
                        tl =
                         {contents =
                           NonEmpty
                            {hd = String "zwischen"; tl = {contents = Empty}}}}}}}}}}}}
val test3a : plist =
  NonEmpty
   {hd = String "why";
    tl =
     {contents =
       NonEmpty
        {hd = String "am";
         tl =
          {contents =
            NonEmpty
             {hd = String "i";
              tl =
               {contents =
                 NonEmpty
                  {hd = String "doing";
                   tl =
                    {contents =
                      NonEmpty {hd = String "this"; tl = {contents = Empty}}}}}}}}}}
*)
let test2a =
  let besatzungszonen = 
    NonEmpty({hd=Int(4);tl=ref (
    NonEmpty({hd=Float(20.);tl=ref (
    NonEmpty({hd=String("scheiss");tl=ref Empty
             }) )
             }) )
             }) 
  and landergrenzen =
    NonEmpty({hd=String("pankow");tl=ref (
    NonEmpty({hd=Int(37);tl=ref (
    NonEmpty({hd=String("zwischen");tl=ref Empty
             }) )
             }) )
             })
  in
append besatzungszonen landergrenzen
let test3a =
  let why = 
    NonEmpty({hd=String("this");tl=ref (
    NonEmpty({hd=String("doing");tl=ref (
    NonEmpty({hd=String("i");tl=ref (
    NonEmpty({hd=String("am");tl=ref (
    NonEmpty({hd=String("why");tl=ref Empty
             }) )
             }) )
             }) )
             }) )
             })
  in
reverse why

(* 3. Write a function that is a constructor for Church numeral
   objects which takes a function as a parameter and carries two
   fields, one to increment the Church numeral from 0 and one to
   apply the current Church numeral to a value. *)

(* I realized this isn't possible because functions are not 
   primative types and cannot be copied the way integers can,
   for example. You can look at this and marvel at my failure
   should you so wish. *)

(*
type 'a church_object = {increment : unit -> unit ; apply : 'a -> 'a}

let c_obj f =
  let fref = ref f 
  and temp = ref f in
    {increment = (fun () -> temp := Ref.copy fref ; fref ;  ) ;
     apply = (fun x -> !fref x) }

let erklarung = c_obj (fun x -> 2. *. x)
*)
(*
let test = 
  let erklarung = c_obj (fun x -> 2. *. x)
  in
erklarung.increment();
erklarung.increment();
erklarung.increment();
erklarung.apply 2.5
*)
