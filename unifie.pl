:- op(20,xfy,?=).

% Prédicats d'affichage fournis

% set_echo: ce prédicat active l'affichage par le prédicat echo
set_echo :- assert(echo_on).

% clr_echo: ce prédicat inhibe l'affichage par le prédicat echo
clr_echo :- retractall(echo_on).

% echo(T): si le flag echo_on est positionné, echo(T) affiche le terme T
%          sinon, echo(T) réussit simplement en ne faisant rien.

echo(T) :- echo_on, !, write(T).
echo(_).


% \+ signifie not


regle(X?=T, rename) :- var(X), var(T).
regle(X?=T, simplify) :- var(X), atomic(T).
regle(X?=T, expand) :- compound(T), \+occur_check(X,T).
regle(X?=T, check) :- X\=T, occur_check(X,T).
regle(T?=X, orient) :- var(X), nonvar(T).
regle(S?=T, decompose) :- functor(S,F1,A1), functor(T,F2,A2), F1==F2, A1==A2.
% regle(S?=T, clash) :-


% Retourne vrai si la variable V apparaît dans le terme T, faux sinon
occur_check(V,T) :- var(T), contains_var(V,T).
occur_check(V,T) :- compound(T), contains_term(V,T);


reduit(rename,X?=T,P,Q) :- X=T.
reduit(simplify,X?=T,P,Q) :- X=T.
reduit(expand,X?=T,P,Q) :- X=T.
reduit(check,X?=T,P,Q) :- X=T.
reduit(orient,T?=X,P,Q) :-
reduit(decompose,E,P,Q) :-
reduit(clash,E,P,Q) :-



% unifie(P).

