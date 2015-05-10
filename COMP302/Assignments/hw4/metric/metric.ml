(* Using modules for Working with different metrics *)

module type METRIC = 
sig 
  type t 
  val unit : t 
  val plus : t -> t -> t 
  val prod : float -> t -> t 
  val toString : t -> string
  val toFloat  : t -> float
  val fromFloat : float -> t
end;;

(* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)
(* Question 1.1 *)
(* Define a module Float which provides an implementation of 
   the signature METRIC; 

   We then want use the module Float to create different representations
   for Meter, KM, Feet, Miles, Celsius, and Fahrenheit, Hour 
*)
(* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)

module Float : METRIC =
struct
  type t = float
  let unit = 1.0
  let plus = ( +. )
  let prod = ( *. )
  let toString x = string_of_float x
  let toFloat x = x
  let fromFloat x = x
end

module Meter = (Float : METRIC)
module KM = (Float : METRIC)
module Feet = (Float : METRIC)
module Miles = (Float : METRIC)
module Celsius = (Float : METRIC)
module Fahrenheit = (Float : METRIC)
module Hour = (Float : METRIC)

(* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)
(* Question 1.2 *)
(* Define a functor Speed which implements the module type SPEED. We 
   want to be able to compute the speed km per hour as well as 
   miles per hour. 

   The functor Speed must therefore be parameterized.
*)
(* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)
 
module type SPEED =  
sig
  type s
  type distance 
  val speed :  distance -> Hour.t -> s 
  val average : s list -> s 
end;;

module Speed (S : METRIC) (D : METRIC) : (SPEED with type s = S.t and type distance = D.t) =
struct
  type s = S.t
  type distance = D.t
  let speed d t = S.fromFloat ( (D.toFloat d) /. (Hour.toFloat (Hour.unit)) )
  let average l = match l with
    | []    -> S.prod 0.0 S.unit
    | x::xs -> List.fold_right ( fun a b -> (S.prod 0.5 (S.plus a b)) ) (x::xs) x
end

(* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)
(* Question 1.3 *)
(* Show how to use the functor Speed to obtain an implementations
   for computing miles per hour in the module MilesPerHour and
   and implementation computing kilometers per hour in the module
   KMPerHour
*)
(* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)

module KMPH = (Float : METRIC)
module MPH = (Float : METRIC)

module MilesPerHour = Speed (MPH) (Miles)
module KMPerHour = Speed (KMPH) (KM)

(* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)
(* Question 1.4 *)
(* It is useful to convert between different metrics.

   Define a module type CONVERSION which specifies the following
   conversion functions:
   - feet2meter          meter = feet * 0.3048
   - fahrenheit2celsius  celsius = (fahrenheit - 32) / 1.8
   - miles2KM            km = miles * 1.60934
   - MilesPerHour2KMPerHour 

   Then implement a module which provides these conversion functions.
*)
(* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)

module type CONVERSION = 
sig
  val feet2meter : Feet.t -> Meter.t
  val fahrenheit2celsius : Fahrenheit.t -> Celsius.t
  val miles2KM : Miles.t -> KM.t
  val milesPerHour2KMPerHour : MPH.t -> KMPH.t
end

module Conversion : CONVERSION =
struct
  let feet2meter x = Meter.fromFloat ( 0.3048 *. (Feet.toFloat x) )
  let fahrenheit2celsius x = Celsius.fromFloat ( (( Fahrenheit.toFloat x ) -. 32.0) /. 1.8 )
  let miles2KM x = KM.fromFloat ( 1.60934 *. (Miles.toFloat x) )
  let milesPerHour2KMPerHour x = KMPH.fromFloat ( 1.60934 *. (MPH.toFloat x) )
end

