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



regle(X?=T, rename) :- var(X), var(T).
regle(X?=T, simplify) :- var(X), atomic(T).
regle(X?=T, expand) :- compound(T), \+occur_check(X,T).
regle(X?=T, check) :- X\==T, occur_check(X,T).
regle(T?=X, orient) :- nonvar(T), var(X).
regle(S?=T, decompose) :- compound(S), compound(T), functor(S,F1,A1), functor(T,F2,A2), F1==F2, A1==A2.
regle(S?=T, clash) :- compound(S), compound(T), functor(S,F1,A1), functor(T,F2,A2), F1 == F2, A1 \== A2.


% Retourne vrai si la variable V apparaît dans le terme T, faux sinon
occur_check(V,T) :- var(V), var(T), V==T.
occur_check(V,T) :- \+subsumes_term(V,T).


reduit(rename,X?=T,[X?=T|Queue],Q) :- X=T, Q=Queue.
reduit(simplify,X?=T,[X?=T|Queue],Q) :- X=T, Q=Queue.
reduit(expand,X?=T,[X?=T|Queue],Q) :- X=T, Q=Queue.
reduit(orient,T?=X,[T?=X|Queue],Q) :- T=X, Q=Queue.
reduit(decompose,S?=T,[S?=T|Queue],Q) :- S=..L1, T=..L2,
	supprimer_premier_elem(L1,Res1), supprimer_premier_elem(L2,Res2),
	decomposer_elem(Res1,Res2,Res),
	append(Res,Queue,Q).

% Supprime le premier élément d'une liste
supprimer_premier_elem([_|Q],Res) :- Res=Q.

% Permet de décomposer les éléments : ex: f(X)?=f(Y) donne X?=Y
% append permet de concatener deux listes
decomposer_elem([H1|Q1],[H2|Q2],Res) :- decomposer_elem(Q1,Q2,Res1), append([H1?=H2],Res1,Res).
decomposer_elem([],[],Res) :- Res = Res.


unifie([]) :- true.
unifie([X?=T|Queue]) :- regle(X?=T,rename), reduit(rename,X?=T,[X?=T|Queue],Q), unifie(Q).
unifie([X?=T|Queue]) :- regle(X?=T,simplify), reduit(simplify,X?=T,[X?=T|Queue],Q), unifie(Q).
unifie([X?=T|Queue]) :- regle(X?=T,expand), reduit(expand,X?=T,[X?=T|Queue],Q), unifie(Q).
unifie([X?=T|_]) :- regle(X?=T,check), fail.
unifie([X?=T|Queue]) :- regle(X?=T,orient), reduit(orient,X?=T,[X?=T|Queue],Q), unifie(Q).
unifie([X?=T|Queue]) :- regle(X?=T,decompose), reduit(decompose,X?=T,[X?=T|Queue],Q), unifie(Q).
unifie([X?=T|_]) :- regle(X?=T,clash), fail.
