module type TREE = 
sig

  
    type 'a tree = Node of 'a * ('a tree) list
    exception NotImplemented
    val find : ('a -> bool) -> 'a tree -> 'a option  					    				    
end
