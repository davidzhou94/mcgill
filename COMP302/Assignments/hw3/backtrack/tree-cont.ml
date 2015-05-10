module TreeCont : TREE = 
struct

  type 'a tree = Node of 'a * ('a tree) list 

  exception NotImplemented 

  let rec find_cont p t c = match t with
    | Node (d, ls) -> if p d then (Some d)
      else find_children_cont p ls c

  and find_children_cont p tree_list c = match tree_list with
    | [] -> c ( )
    | x::xs -> find_cont p x (fun ( ) -> find_children_cont p xs c)

  let find p t = find_cont p t (fun ( ) -> None)

end
