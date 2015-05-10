module type LOCK = 
  sig
    type key
    type lock

    val create_lock : string -> (key * lock)
      (* creates a lock and the key that fits it, based on a password *)

    val is_locked : lock -> bool
      (* returns true if the lock is locked, false if not *)

    val toggle_lock: lock ->  key -> lock
      (* If the key matches the lock, a new lock will be returned with
       its status changed from locked to unlocked or vice versa.   
       If not, the lock will be returned unchanged. *)

  end 

module type LOCKED_KEY  =
sig
  include KEY
  val comes_locked : bool
end

module Lock (K : LOCKED_KEY) : (LOCK with type key = K.key) = 
struct
  exception TODO

  type key = K.key
  type lock = key * bool

(* ----------------------------------------------------------------- *)
(* Question 1.1: 5 points *)
(* ----------------------------------------------------------------- *)
(* Implement the function  create_lock : string -> (key * lock) *)

  let create_lock str = 
    let generated_key = K.create_key str
    in
  ( generated_key, (generated_key, K.comes_locked) )

(* ----------------------------------------------------------------- *)   

  let is_locked (lock_key, status) = status

(* ----------------------------------------------------------------- *)
(* Question 1.3: 5 points *)
(* ----------------------------------------------------------------- *)
(* Implement the function toggle_lock *)
  let toggle_lock (lock_key, status) try_key = match (K.keys_match try_key lock_key) with
              | true  -> (match status with
                            | true  -> (lock_key, false)
                            | false -> (lock_key, true) )
              | false -> (lock_key, status)

end


(* ----------------------------------------------------------------- *)
(* Question 1.4: 5 points *)
(* ----------------------------------------------------------------- *)
(* Create a module SimpleLock which provides the implementation of 
   a simple lock where the key is simply a string and the lock comes
   already locked, i.e. the status comes_locked is true.
*)

module Locked_String_Key : LOCKED_KEY =
struct
  include StringKey
  let comes_locked = true
end

module SimpleLock = 
struct
  include Lock(Locked_String_Key)
end

(* ----------------------------------------------------------------- *)
(* Question 1.5: 5 points *)
(* ----------------------------------------------------------------- *)
(* Create a structure ComboLock which provides the implementation of 
   a combination lock where the key is a 
   already locked, i.e. the status comes_locked is true.

*)

module Locked_Combo_Key : LOCKED_KEY =
struct
  include ComboKey
  let comes_locked = true
end

module ComboLock = 
struct
  include Lock(Locked_Combo_Key)
end
