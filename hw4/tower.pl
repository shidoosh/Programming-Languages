tower(N, T, C) :-
	mylength(N, T),
  	maplist(mylength(N), T),	
	% row and cols distinct values 1 through N inclusive 
  	transpose(T, RT),		
  	maplist(unique(N), T),
  	maplist(unique(N), RT),
  	% instantiate values
	maplist(fd_labeling, RT),	
  	% get the corresponding counts 
	getCounts(T, C).

%same procedure as tower predicate, but helper predicates 
%do not user GNU finite domain solver
plain_tower(N, T, C) :-
        mylength(N, T),
        maplist(mylength(N), T),
        transpose(T, RT),
        maplist(plain_unique(N), T),
        maplist(plain_unique(N), RT),
        getCounts(T, C).

%plain_tower:tower performance
speedup(R):-
	statistics(cpu_time, [Start0|_]),
	plain_tower(8, [[5,8,6,2,7,4,3,1],
                       [6,4,3,8,2,1,5,7],
                       [4,3,7,5,1,8,6,2],
                       [3,5,1,6,4,7,2,8],
                       [7,2,8,1,5,6,4,3],
                       [8,7,5,4,3,2,1,6],
                       [1,6,2,3,8,5,7,4],
                       [2,1,4,7,6,3,8,5]], _),
	statistics(cpu_time, [Stop0|_]),
	R0 is Stop0-Start0,
	statistics(cpu_time, [Start1|_]),
        tower(8, [[5,8,6,2,7,4,3,1],
                       [6,4,3,8,2,1,5,7],
                       [4,3,7,5,1,8,6,2],
                       [3,5,1,6,4,7,2,8],
                       [7,2,8,1,5,6,4,3],
                       [8,7,5,4,3,2,1,6],
                       [1,6,2,3,8,5,7,4],
                       [2,1,4,7,6,3,8,5]], _),
        statistics(cpu_time, [Stop1|_]),  
	R1 is Stop1-Start1, 
	R is R0/R1. 

ambiguous(N, C, T1, T2):-
        tower(N, T1, C),
        tower(N, T2, C).
	
%contruct counts(T, B, L, R)
getCounts(T, C) :-
	findTop(T, Top),
	findBottom(T, Bottom), 
	findLeft(T, Left), 
	findRight(T, Right), 
	C = counts(Top, Bottom, Left, Right).  

%L is a list
%N is always the first element
%This predicate finds the count for tower puzzle given a list and its head
%Inspired by a predicate that counts all elements greater than N, but modified for tower purposes.
%call this signature, user friendly
count_elems(L, N, Count) :-
	[H|_] = L,
    	count_elems(L, H, N, 0, Count).             %"initialize" Acc to 0.
count_elems([H|T], OldH, N, Acc, Count) :-
    	H >= N,                                     % count this element if its >= N AND
    	H >= OldH,                                  % if it is greater than the greatest previous element
    	Acc1 is Acc + 1,                            % increment the accumulator
    	count_elems(T, H, N, Acc1, Count).          % check the rest of the list
%The following clauses consider when the above fails, that is, when H < N or H < OldH.
%We need to cut here for each rule as it does the same thing, and we only want one execution
%(even if, say, both failure conditions occured).
count_elems([H|T], OldH, N, Acc, Count) :-         
    	H < N,                                      % don't count this element if it's < N
    	count_elems(T, OldH, N, Acc, Count), !.     % check rest of list (w/out incrementing acc)
count_elems([H|T], OldH, N, Acc, Count) :-
    	H < OldH,                                   % don't count this element if it's < OldH
    	count_elems(T, OldH, N, Acc, Count), !.     % check rest of list (w/out incrementing acc)
% instantiate total with accumulator
count_elems([], _, _, Count, Count).


gethead(L, H) :-
        [H|_] = L.


findLeft(T, L) :-
        maplist(gethead, T, Heads),
        maplist(count_elems, T, Heads, L).

%same method as findLeft, but reverse the list first
findRight(T, L) :-
        maplist(rev, T, RT),
        maplist(gethead, RT, Heads),
        maplist(count_elems, RT, Heads, L).

%for Top and Bottom counts, need to extract "lists" for columns
findCols(T,L):-
        transpose(T, L).

%with findCols, same procedure as findLeft
findTop(T,L):-
        findCols(T,Cols),
        maplist(gethead, Cols, Heads),
        maplist(count_elems, Cols, Heads, L).

%same method as findTop, but reverse the list first
findBottom(T,L):-
        findCols(T,Cols),
        maplist(rev, Cols, RC),
        maplist(gethead, RC, Heads),
        maplist(count_elems, RC, Heads, L).

%not plain helper predicates:
domain(N, L) :-
  	fd_domain(L, 1, N).

mylength(N, T) :-
  	length(T, N).

unique(N, T) :-
	fd_all_different(T),
  	maplist(domain(N), T).


%plain helper predicates: 
bounds(M, Range) :-
	findall(Ele, between(1, M, Ele), Range).

plain_domain(M, Ele) :-
  	bounds(M, Range),
  	member(Ele, Range).

noduplicates(L) :-
	length(L, LLength),
        sort(L, LS),
        length(LS, LSlength),
        (LLength == LSlength).

plain_unique(N, T) :-
	maplist(plain_domain(N), T),
  	noduplicates(T).


%Credit: https://stackoverflow.com/questions/4280986/how-to-transpose-a-matrix-in-prolog/
%TA on Piazza said it was ok to use the source code, since transpose is not supported on gprolog 
transpose([], []).
transpose([F|Fs], Ts) :-
transpose(F, [F|Fs], Ts).

transpose([], _, []).
transpose([_|Rs], Ms, [Ts|Tss]) :-
lists_firsts_rests(Ms, Ts, Ms1),
transpose(Rs, Ms1, Tss).

lists_firsts_rests([], [], []).
lists_firsts_rests([[F|Os]|Rest], [F|Fs], [Os|Oss]) :-
lists_firsts_rests(Rest, Fs, Oss).

%Credit: Exercise on Ohio State website
rev(M, M2) :- halves(M, [], M2).
halves([X|T], Acc, M2) :- halves(T, [X|Acc], M2).
halves([], X, X).
