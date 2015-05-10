module  Parser : PARSER = 
struct

(* In this exercise, you implement a  parser for a
 simple context free grammar using continuations. The grammar parses arithmetic
 expressions with +,*, and ()'s.  The n represents an integer and is a
 terminal symbol. Top-level start symbol for this grammar is E.  

E-Expression: E ::= S;          
S-Expression: S ::= P + S | P   
P-expression: P ::= A * P | A   
A-expression: A ::= n | (S)

How to read the grammar? - There are 4 different kinds of expressions:
E-expresion (top-level expression), 
S-expression (an expression with top-level symbol + ), 
P-expression (an expression with top-level symbol * ), and 
A-expression (an atomic expression, i.e. either a number or an expression in 
              brackets).

More precisely the grammar gives an answer to the following 4 questions: 

What is an E-expression? - It is a S-expression followed by a semicolon.

What is an S-expression? - It is a P-expression followed by "+" and another
   S-expression OR simply a P-expression

What is a P-expression? - It is an A-expression followed by "*" and another
   P-expression OR simply an A-expression.

What is an A-expression? - It is an atomic expression; either it is simply a
   number or it is a S-expression wrapped in brackets.

Note according to this grammar * binds tighter than +, as is also usually the case.

Expressions wil be lexed into a list of tokens of type Token.

For example "9 + 8 * 7;" is turned by the lexer into a list of tokens
[INT(9),PLUS,INT(8),TIMES,INT(7),SEMICOLON].

We then call the parser to translate the list of tokens into an abstract syntax
tree following the rules of the grammar.

   parse [INT(9),PLUS,INT(8),TIMES,INT(7),SEMICOLON]
   ===> Sum(Int 9, Prod (Int 8, Int 7))

The principles we use here are similar to the regular expression
matcher discussed in class. As we get the list of tokens we do not know how to
split it such that we can form  a proper S-expression. Instead, we will process the
token list together with a continuation: token list -> exp -> exp.

Part of the token list will be used to build an expression e1. The continuation receives the remaining
token list toklist' for further processing and the expression e1. It will then continue to
parse toklist' and build compound expressions given e1.

For example, to parse a S-expression we use part of the token list to build a P-expression, called e; when we are done 
the continuation receives a remaining token list, called tok_list', together with an expression e. 
Following the grammar rules, if tok_list' contains as a next token PLUS, we continue building an S-expression;
otherwise we simply return e which is also a valid S-expression.

If parsing was successful, the token stream will eventually be empty,
and we can simply return the built expression e.


*)


module L = Lexer

type exp = Sum of exp * exp | Prod of exp * exp | Int of int

exception Error of string

let rec parseExp toklist sc = match toklist with
  | [ ] -> raise (Error "Error: Incomplete expression")
  | _ -> parseSum toklist (fun toklist' e -> match toklist' with [] -> raise (Error "Closing semi-colon expected") | x::xs -> ( match x with L.SEMICOLON -> sc xs e | _ -> raise (Error "Closing semi-colon expected") ) )

and parseSum toklist sc = match toklist with
  | [ ] -> raise (Error "Error: Incomplete expression")
  | _ -> parseProd toklist (fun toklist' e1 -> match toklist' with [] -> sc toklist' e1 | x::xs -> ( match x with L.PLUS -> parseSum xs (fun s e2 -> sc s (Sum (e1, e2)) ) | _ -> sc toklist' e1 ) )

and parseProd toklist sc = match toklist with
  | [ ] -> raise (Error "Error: Incomplete expression")
  | _ -> parseAtom toklist (fun toklist' e1 -> match toklist' with [] -> sc toklist' e1 | x::xs -> ( match x with L.TIMES -> parseProd xs (fun s e2 -> sc s (Prod (e1, e2)) ) | _ -> sc toklist' e1 ) )
	      
and parseAtom toklist sc = match toklist with
  | [ ] -> raise (Error "Error: Incomplete expression")
  | x::xs -> match x with 
      | L.INT n -> sc xs ( Int(n) )
      | L.LPAREN -> parseSum xs (fun toklist' e -> match toklist' with [] -> raise (Error "Incomplete A-Exp") | h::t -> ( match h with L.RPAREN -> sc t e | _ -> raise (Error "Closing parenthesis expected" ) ) )
      | _ -> raise (Error "Malformed expression")

let parse string  = parseExp (L.lex string) (fun s e -> match s with [] -> e | _ -> raise (Error "Error: Incomplete expressionT"))

end


