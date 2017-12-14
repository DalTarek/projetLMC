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

% unif(P,S): inhibe la trace d'affichage des règles
unif(P,S) :- clr_echo, unifie(P,S).

% trace_unif(P,S): active la trace d'affichage des règles
trace_unif(P,S) :- set_echo, unifie(P,S).

% Définition du prédicat regle(E,R)
regle(X?=T, rename) :- var(X), var(T).
regle(X?=T, simplify) :- var(X), atomic(T).
regle(X?=T, expand) :- var(X), compound(T), \+occur_check(X,T).
regle(X?=T, check) :- X\==T, occur_check(X,T).
regle(T?=X, orient) :- nonvar(T), var(X).
regle(S?=T, decompose) :- compound(S), compound(T), functor(S,F1,A1), functor(T,F2,A2), F1==F2, A1==A2.
regle(S?=T, clash) :- compound(S), compound(T), functor(S,F,A) \== functor(T,F,A).

% Retourne vrai si la variable V apparaît dans le terme T, faux sinon
occur_check(V,T) :- var(V), var(T), V==T.
occur_check(V,T) :- \+subsumes_term(V,T).

% Définition du prédicat reduit(R,E,P,Q)
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
decomposer_elem([],[],_).

% Stratégies : 

% Stratégie choix_premier(P,Q,E,R)
% rename > simplify > expand > check > orient > decompose > clash 
unifie([], choix_premier) :- true.
unifie([X?=T|Queue], choix_premier) :- regle(X?=T,rename), echo('systeme:  '), echo([X?=T|Queue]), echo('\n'), echo('rename:   '), echo(X?=T), echo('\n'), reduit(rename,X?=T,[X?=T|Queue],Q), unifie(Q, choix_premier).
unifie([X?=T|Queue], choix_premier) :- regle(X?=T,simplify), echo('systeme:  '), echo([X?=T|Queue]),echo('\n'), echo('simplify:   '), echo(X?=T),echo('\n'),  reduit(simplify,X?=T,[X?=T|Queue],Q), unifie(Q, choix_premier).
unifie([X?=T|Queue], choix_premier) :- regle(X?=T,expand), echo('systeme:  '), echo([X?=T|Queue]), echo('\n'), echo('expand:   '), echo(X?=T),echo('\n'),  reduit(expand,X?=T,[X?=T|Queue],Q), unifie(Q, choix_premier).
unifie([X?=T|_], choix_premier)     :- regle(X?=T,check), echo('systeme:  '), echo([X?=T|_]),echo('\n'), echo('check:   '), echo(X?=T), echo('\n'),  fail.
unifie([X?=T|Queue], choix_premier) :- regle(X?=T,orient), echo('systeme:  '), echo([X?=T|Queue]), echo('\n'), echo('orient:   '), echo(X?=T),echo('\n'), reduit(orient,X?=T,[X?=T|Queue],Q), unifie(Q, choix_premier).
unifie([X?=T|Queue], choix_premier) :- regle(X?=T,decompose), echo('systeme:  '), echo([X?=T|Queue]), echo('\n'), echo('decompose:   '), echo(X?=T),echo('\n'),  reduit(decompose,X?=T,[X?=T|Queue],Q), unifie(Q, choix_premier).
unifie([X?=T|_], choix_premier)     :- regle(X?=T,clash), echo('systeme:  '), echo([X?=T|_]), echo('\n'), echo('clash:   '), echo(X?=T), echo('\n'),  fail.

% Stratégie choix_pondere(P,Q,E,R)
% clash, check > rename, simplify > orient > decompose > expand
unifie([], choix_pondere) :- true.
unifie([X?=T|_], choix_pondere)     :- regle(X?=T,clash), echo('systeme:  '), echo([X?=T|_]), echo('\n'), echo('clash:   '), echo(X?=T), echo('\n'),  fail.
unifie([X?=T|_], choix_pondere)     :- regle(X?=T,check), echo('systeme:  '), echo([X?=T|_]),echo('\n'), echo('check:   '), echo(X?=T), echo('\n'),  fail.
unifie([X?=T|Queue], choix_pondere) :- regle(X?=T,rename), echo('systeme:  '), echo([X?=T|Queue]), echo('\n'), echo('rename:   '), echo(X?=T), echo('\n'), reduit(rename,X?=T,[X?=T|Queue],Q), unifie(Q, choix_pondere).
unifie([X?=T|Queue], choix_pondere) :- regle(X?=T,simplify), echo('systeme:  '), echo([X?=T|Queue]),echo('\n'), echo('simplify:   '), echo(X?=T),echo('\n'),  reduit(simplify,X?=T,[X?=T|Queue],Q), unifie(Q, choix_pondere).
unifie([X?=T|Queue], choix_pondere) :- regle(X?=T,orient), echo('systeme:  '), echo([X?=T|Queue]), echo('\n'), echo('orient:   '), echo(X?=T),echo('\n'), reduit(orient,X?=T,[X?=T|Queue],Q), unifie(Q, choix_pondere).
unifie([X?=T|Queue], choix_pondere) :- regle(X?=T,decompose), echo('systeme:  '), echo([X?=T|Queue]), echo('\n'), echo('decompose:   '), echo(X?=T),echo('\n'),  reduit(decompose,X?=T,[X?=T|Queue],Q), unifie(Q, choix_pondere).
unifie([X?=T|Queue], choix_pondere) :- regle(X?=T,expand), echo('systeme:  '), echo([X?=T|Queue]), echo('\n'), echo('expand:   '), echo(X?=T),echo('\n'),  reduit(expand,X?=T,[X?=T|Queue],Q), unifie(Q, choix_pondere).





