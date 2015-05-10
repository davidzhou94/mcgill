module List_Library : TAILREC_LIST_LIBRARY = 
  struct
    (* We reimplement some of OCaml's list library functions tail-recursively. As a
     result, these functions will be able to run on large lists and we will not
     get a stack overflow.
     
     *)
    
    exception NotImplemented
		
    (* partition list *)
    (* partition : ('a -> bool) -> 'a list -> 'a list * 'a list
     
     partition p l returns a pair of lists (l1, l2), where l1 is the list of all the elements of l 
     that satisfy the predicate p, and l2 is the list of all the elements of l that donot satisfy p. 
     The order of the elements in the input list is preserved.
     
     *)

    let rec partition_tr p list (acc1, acc2) = match list with
      | []    -> (acc1, acc2)
      | x::xs -> 
        if p x then 
          partition_tr p xs (acc1@[x], acc2)
        else 
          partition_tr p xs (acc1, acc2@[x])

    let partition p list = 
      partition_tr p list ([], [])
				 
  end
