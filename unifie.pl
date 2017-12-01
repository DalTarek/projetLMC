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
regle(X?=T, check) :- X\==T, occur_check(X,T).
regle(T?=X, orient) :- nonvar(T), var(X).
regle(S?=T, decompose) :- functor(S,F1,A1), functor(T,F2,A2), F1==F2, A1==A2.
regle(S?=T, clash) :- functor(S,F,A) \== functor(T,F,A).


% Retourne vrai si la variable V apparaît dans le terme T, faux sinon
occur_check(V,T) :- var(V), var(T), V==T.
occur_check(V,T) :- \+ subsumes_term(V,T).



reduit(rename,X?=T,[X?=T|Queue],Q) :- X=T, Q=Queue.
reduit(simplify,X?=T,[X?=T|Queue],Q) :- X=T, Q=Queue.
reduit(expand,X?=T,[X?=T|Queue],Q) :- X=T, Q=Queue.
reduit(orient,T?=X,[T?=X|Queue],Q) :- T=X, Q=Queue.
%reduit(decompose,E,P,Q) :-


unifie([]) :- true.
unifie([X?=T|Queue]) :- regle(X?=T,rename), reduit(rename,X?=T,[X?=T|Queue],Q), unifie(Q).
unifie([X?=T|Queue]) :- regle(X?=T,simplify), reduit(simplify,X?=T,[X?=T|Queue],Q), unifie(Q).
unifie([X?=T|Queue]) :- regle(X?=T,expand), reduit(expand,X?=T,[X?=T|Queue],Q), unifie(Q).
unifie([X?=T]) :- regle(X?=T,check), fail.
unifie([X?=T|Queue]) :- regle(X?=T,orient), reduit(orient,X?=T,[X?=T|Queue],Q), unifie(Q).
%unifie([X?=T|Queue]) :- regle(X?=T,decompose), reduit(decompose,X?=T,[X?=T|Queue],Q), unifie(Q).
unifie([X?=T]) :- regle(X?=T,clash), fail.
