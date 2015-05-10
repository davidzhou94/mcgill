module type SPREADSHEET = 
  sig

    exception NotImplemented
    type exp

    type spreadsheet 
    type column

    val num : int ref -> exp
    val add : exp -> exp -> exp
    val mult: exp -> exp -> exp

    val initialize: (int ref) list list -> spreadsheet 
    val add_column: spreadsheet -> column -> spreadsheet 
    val compute_column: spreadsheet -> (exp list -> exp) -> column

    val update_cell  : int ref * int -> unit
    val update_exp   : exp -> unit 
    val update_column: column -> unit 
    val update_sheet : spreadsheet -> unit 
					       
  end
