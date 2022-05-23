(*1*)
let my_subset_test0 = subset [] []
let my_subset_test1 = subset [1;2;3] [1;2;3;4;5]
let my_subset_test2 = not(subset [1;2;3;4;5] [1; 2; 3])
let my_subset_test3 = subset [1] [1] 

(*2*)
let my_equal_sets_test0 = equal_sets [] []
let my_equal_sets_test1 = equal_sets [1;2;3] [1;2;3]
let my_equal_sets_test2 = not(equal_sets [4;5;6] [7;8;9])
let my_equal_sets_test3 = equal_sets [9;8;7] [7;8;9] 

(*3*)
let my_set_union_test0 = equal_sets (set_union [1;2;] [3;]) [1;2;3]
let my_set_union_test1 = equal_sets (set_union [1] [1]) [1;1] 

(*4*)
let my_set_intersection_test0 = equal_sets (set_intersection [1;2;3] [4;5;6]) []
let my_set_intersection_test1 = equal_sets (set_intersection [1;2;3] [2;3;4]) [2;3]

(*5*)
let my_set_diff_test0 = equal_sets (set_diff [1;2;3] [1;2;3]) []
let my_set_diff_test1 = equal_sets (set_diff [1;2;3] [2;3;4]) [1]

(*6*)
let my_computed_fixed_point_test0 = computed_fixed_point (=) (fun x -> x *. 2.) 4. = infinity

(*7*)
let my_computed_periodic_point_test0 = computed_periodic_point (=) (fun x -> x * -1) 2 4 = 4;;

(*8*)
let my_while_away_test0 = equal_sets (while_away ((+) 2) ((>) 10) 0) [0; 2; 4; 6; 8]

(*9*)
let my_rle_decode_test0 = equal_sets (rle_decode [1, "m"; 1, "i"; 2, "s"; 1, "i"; 2, "p"; 1, "i"]) ["m"; "i"; "s"; "s"; "i"; "p"; "p"; "i"]
let my_rle_decode_test1 = equal_sets (rle_decode [1, "b"; 3, "r"]) ["b"; "r"; "r"; "r"]

(*10*)
(* testing filter_blind_alleys *)
type closet_nonterminals = 
| Closet | Shoes | Shirt | Pants

let closet_rules = 
	[Closet, [N Shoes; N Shirt; N Pants]; 
	Shoes, [T"Heels"]; 
	Shoes, [T"Sneakers"]; 
	Shirt, [T"Strapless"]; 
	Shirt, [T"Buttoned"];
	Pants, [T"Jeans"]; 
	Pants, [T"Shorts"]]

let closet_grammar = Closet, closet_rules

let my_filter_blind_alleys_test0 = filter_blind_alleys closet_grammar = closet_grammar
let my_filter_blind_alleys_test1 = filter_blind_alleys(Closet, [Closet, [N Shoes; N Shirt; N Pants];
        Shoes, [T"Heels"];
        Shoes, [T"Sneakers"];
        Shirt, [T"Strapless"];
        Shirt, [T"Buttoned"];
        Pants, [T"Jeans"];
        Pants, [T"Shorts"]])
