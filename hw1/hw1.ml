(* Note: first::last notation... first and last are not keywords. Can use anything! *)
(* List module needed for mem function involved in filter_blind_alleys *)
open List;;

(* for subset, set_intersection, set_diff *)
let rec has x y =
	match y with
	[] -> false
	| h::t -> if x = h then true 
	else has x t;;

(* 1. Write a function subset a b that returns true iff a⊆b, 
i.e., if the set represented by the list a is a subset 
of the set represented by the list b. 
Every set is a subset of itself. 
This function should be generic to lists of any type: 
that is, the type of subset should be a generalization of 
'a list -> 'a list -> bool. *)
(* Used helper function to check if all elements in a are in b *)	
let rec subset a b = 
	match a with
	[] -> true
	| h::t -> if (has h b) = false then false
	          else subset t b;;
(* 2. Write a function equal_sets a b that returns true iff the represented sets are equal. *)
(* If one set is a subset of another, and the other is a subset
of the one in question, the two sets must be the same. So, if this is not
the case, report false *)
let equal_sets a b =
	if a == [] && b == [] then true
	else subset a b && subset b a;;

(* 3. Write a function set_union a b that returns a list representing a∪b. *) 
(* Duplicates are okay, so can just append *)
let set_union a b = a@b;;


(* 4. Write a function set_intersection a b that returns a list representing a∩b.*)
(* Used helper function to check the elements that they both have *)
let rec set_intersection a b = 
	match a with
	| [] -> []
	| h::t -> if has h b then h::set_intersection t b
		  else set_intersection t b;;

(* 5. Write a function set_diff a b that returns a list representing a−b, 
that is, the set of all members of a that are not also members of b.*)
(* Used helper function to check if that element is in set in question, 
getting elements unique to a relative to set b *)
let rec set_diff a b = 
	match a with
	| [] -> []
	| h::t -> if (has h b) then (set_diff t b)
		  else h::(set_diff t b);;

(* 6. Write a function computed_fixed_point eq f x that 
returns the computed fixed point for f with respect to x, 
assuming that eq is the equality predicate for f's domain *)
let rec computed_fixed_point eq f x =
	if eq x (f x) then x
	else computed_fixed_point eq f (f x);;

(* 7. Write a function computed_periodic_point eq f p x that 
returns the computed periodic point for f with period p and 
with respect to x, assuming that eq is the equality predicate for f's domain. *)
let rec computed_periodic_point eq f p x = 
	match p with
	| 0 -> x
	| _ -> if eq x (f (computed_periodic_point eq f (p-1) (f x))) 
		then x 
		else (computed_periodic_point eq f p (f x));;
(* 8. Write a function while_away s p x that returns the longest list 
[x; s x; s (s x); ...] such that p e is true for every 
element e in the list. *)
let rec while_away s p x = 
	if (p x) then x::while_away s p (s x) 
	else [];;

(* helper function for rle_decode *)
let rec pair n e l =
	if n = 0 then l
    	else (pair (n-1) e l@[e]);;

(* 9. Write a function rle_decode lp that decodes 
a list of pairs lp in run-length encoding form. *)
let rec rle_decode lp = 
	match lp with
	[] -> []
	| h::t -> match h with (n,e) -> (pair n e [])@(rle_decode t);;

(* filter_blind_alley code: *)
(* 10. Write a function filter_blind_alleys g that returns a 
copy of the grammar g with all blind-alley rules removed. 
This function should preserve the order of rules: 
that is, all rules that are returned should be in the same 
order as the rules in g. *)

(* define symbol type *)
(* Credit: Denoted in spec *) 
type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

(* match the terminal symbols, List module contains mem function *)
let terminal_symbol a terminals= 
	match a with 
	T sym -> true
	| N sym -> mem sym terminals;;

(* get the rule *)
let rec terminal_rule rhs terminals = 
	match rhs with
	[] -> true
	| h::t -> if terminal_symbol h terminals then terminal_rule t terminals
	else false;;

(* filtering rules *)
let rec check a terminals =
	match a with
	[] -> terminals
	| (lhs,rhs)::t-> if terminal_rule rhs terminals then 
	if mem lhs terminals then check t terminals 
		else check t (lhs::terminals)
	else check t terminals;;

(* perserve the order, as specified *)
let rec order a b =
        match a with
        [] -> []
        | h::t-> match h with
        _,p -> if terminal_rule p b then [h]@order t b
        else order t b;;

let isEqual a b c = equal_sets a c;;

let rec point eq a b c = 
	if isEqual (a b c) b c then c 
	else point eq a b (a b c);;

(* And, finally: *)
let filter_blind_alleys g =
	match g with
	| (a, b) -> (a, order b (point isEqual check b []));;
