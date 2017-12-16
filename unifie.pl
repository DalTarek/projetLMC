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
regle(S?=T, clash) :- compound(S), compound(T), functor(S,F,A) \= functor(T,F,A).

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

afficher_trace(P,E,R) :- echo('systeme:  '), echo(P), echo('\n'), echo(R), echo(':  '), echo(E), echo('\n').

% Stratégies : 

% Stratégie choix_premier(P,E,R)
% rename > simplify > expand > check > orient > decompose > clash 

unifie([],choix_premier) :- true.
unifie(P,choix_premier) :- choix_premier(P,E,R), afficher_trace(P,E,R), reduit(R,E,P,Q), !, unifie(Q,choix_premier).


% Stratégie choix_pondere(P,E,R)
% clash > check > rename > simplify > orient > decompose > expand

unifie([],choix_pondere) :- true.
unifie(P,choix_pondere) :- choix_pondere(P,E,R), afficher_trace(P,E,R), reduit(R,E,P,Q), !, unifie(Q,choix_pondere).


% Classement des différentes règles du poids le plus fort au plus faible
liste_regles([clash,check,rename,simplify,orient,decompose,expand]).


% Choisit la règle dans l'ordre du prédicat regle
choix_premier([E|_],E,R) :- regle(E,R),!.


% Choisit la regle ayant le poids le plus élevé dans l'ordre donné dans la liste liste_regle
choix_pondere(P,E,R) :- liste_regles(A), parcourir_regle(P,E,R,A),!.

parcourir_regle(P,E,R,A) :- parcourir_equation(P,E,R,A).
parcourir_regle(P,E,R,[_|Queue]) :- parcourir_regle(P,E,R,Queue).

parcourir_equation([E|_],E,R,[R|_]) :- regle(E,R).
parcourir_equation([_|Queue],E,R,A) :- parcourir_equation(Queue,E,R,A).
parcourir_equation([],_,_,_) :- fail. 

