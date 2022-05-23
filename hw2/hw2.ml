type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal;;

let rec convert nonterminal = function
        | [] -> []
        (* if lhs is nonterminal, join rhs with the rest, otherwise keep searching *)
        | (lhs,rhs)::rest ->
                if (lhs=nonterminal)
                        then rhs::(convert nonterminal rest)
                else (convert nonterminal rest);;

(*fst retrieves first element of the tuple, snd retrieves the second element*)
let convert_grammar gram1 =
        (fst gram1, fun nonterminal -> convert nonterminal (snd gram1));;

(* have to derive the rule given a grammar. start with leftmost symbol *)
let rec derive_rule rules acceptor derivation frag = function
          | [] -> acceptor derivation frag
          | curr::rest ->
          (  (* if the grabbed fragment is terminal, need to check against the remaining
                        fragment and the remaining symbols 
		if nonterminal, check if rule is accepted, via test_rules *)
                match curr with
                        | T(terminal) ->
                        (
                                match frag with
                                 | [] -> None
                                 | curr::tail -> (
                                if (curr = terminal)
                                        then (derive_rule rules acceptor derivation tail rest)
                                else None
                                )
                        )
                        | N(nonterminal) ->
                          (
                                test_rules rules nonterminal
	                        (fun derivation frag -> derive_rule rules acceptor derivation frag rest)                                                   		     derivation frag (rules nonterminal)
                          )
          )

(* "and" keyword allows for forward declaration behavior. derive_rule can call test_rules *)            
and test_rules rules nonterminal acceptor derivation frag = function
                |[] -> None 
                | curr::rest -> (
                match (derive_rule rules acceptor ((fun x y -> x @ [y]) derivation (nonterminal, curr)) frag curr) with
                         | None -> (test_rules rules nonterminal acceptor derivation frag rest)
                         | some -> some
                )


let parse_prefix gram = fun acceptor frag -> (
        match gram with
                (leftmost, rules) -> test_rules rules leftmost acceptor [] frag (rules leftmost)
);;
