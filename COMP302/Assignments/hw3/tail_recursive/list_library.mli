module type TAILREC_LIST_LIBRARY = 
sig

  exception NotImplemented

  val partition :  ('a -> bool) -> 'a list -> 'a list * 'a list

end
