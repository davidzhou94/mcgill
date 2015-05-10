module type TREE = 
sig

    type 'a tree = Node of 'a * ('a tree) list

    val find : ('a -> bool) -> 'a tree -> 'a option  					    				    
end

module TreeOpt : TREE = 
struct

type 'a tree = Node of 'a * ('a tree) list 


let rec find p t = match t with
  | Node (x, children) -> 
      if p x then Some x
      else find_children p children

and find_children p tree_list = match tree_list with
  | [] -> None
  | t::ts -> (match find p t with None -> find_children p ts | Some d -> Some d)

end
