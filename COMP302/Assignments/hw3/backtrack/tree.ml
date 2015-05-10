module Tree : TREE = 
struct

  type 'a tree = Node of 'a * ('a tree) list 

  exception NotFound

  let rec find_exn p t = match t with
  | Node (x, children) -> 
     if p x then x
     else find_children_exn p children
			    
  and find_children_exn p tree_list = match tree_list with
    | [] -> raise NotFound
    | t::ts -> (try find_exn p t with NotFound -> find_children_exn p ts)


  let find p t = 
    try Some(find_exn p t) with NotFound -> None
end
