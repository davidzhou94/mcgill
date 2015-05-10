module type KEY = 
sig
  type key   (* abstract *)

  val create_key : string -> key
    (* returns a unique key based on a password each time it is called, 
       using references to ensure unique keys *) 

  val keys_match : key ->  key -> bool
    (* determines whether two keys are equal *)
end

module StringKey : KEY = 
struct
  type key = string

  let key_index = ref 0 

  let inc_index () = key_index := !key_index + 1
  let create_key str = (inc_index () ; str ^ string_of_int (!key_index))

  let keys_match x y = x = y

end


module ComboKey : KEY = 
struct
  type key = int list

  let key_index = ref 0 

  let inc_index () = key_index := !key_index + 1

 let rec tabulate f n = 
    let rec tab n acc = 
      if n = 0 then (f 0)::acc
      else tab (n-1) ((f n)::acc)
    in
      tab n []

  (* string_explode : string -> char list *)
  let string_explode s = 
    tabulate (fun n -> String.get s n) ((String.length s) - 1)

  let create_key str = 
    let c = string_explode str 
    in 
      List.map (fun x -> (inc_index () ; Char.code x + !key_index)) c

  let keys_match x y = x = y

end

