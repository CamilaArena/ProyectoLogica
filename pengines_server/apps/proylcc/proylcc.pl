:- module(proylcc,
	[  
		put/8
	]).

:-use_module(library(lists)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% replace(?X, +XIndex, +Y, +Xs, -XsY)
%
replace(X, 0, Y, [X|Xs], [Y|Xs]).

replace(X, XIndex, Y, [Xi|Xs], [Xi|XsY]):-
    XIndex > 0,
    XIndexS is XIndex - 1,
    replace(X, XIndexS, Y, Xs, XsY).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% put(+Contenido, +Pos, +PistasFilas, +PistasColumnas, +Grilla, -GrillaRes, -FilaSat, -ColSat).
%

% Inserta el contenido en la posicion RowN,ColN de la Grilla del juego, y verifica si la fila y columnas ubicadas
% en esa posicion satisfacen las pistas correspondientes. Retorna 1 o 0 en filaSat, dependiendo si la fila satisface  
%  las pistas, y lo mismo para colSat.
put(Contenido, [RowN, ColN], PistasFilas, PistasColumnas, Grilla, NewGrilla, FilaSat, ColSat):-

   replace(Row, RowN, NewRow, Grilla, NewGrilla),	    
	(replace(Cell, ColN, _, Row, NewRow),
	Cell == Contenido 
		;
	replace(_Cell, ColN, Contenido, Row, NewRow)),    

   nth0(RowN, PistasFilas, PistasDeLaFila),

   nth0(ColN, PistasColumnas, PistasDeLaColumna),

   getFila(RowN, NewGrilla, ListaFila), 

   getColumna(ColN, NewGrilla, ListaColumna),

   verificarFila(PistasDeLaFila, ListaFila, FilaSat),

   verificarColumna(PistasDeLaColumna, ListaColumna, ColSat).	


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% getColumna(+Indice, +Matriz, -Columna)
%

% Retorna la columna ubicada en el Indice de la Matriz
getColumna(Indice, Matriz, Columna):-
    getColumnaAux(Indice,Matriz,[],Columna).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% getColumnaAux(+Indice,+Matriz,+[],-Columna)
%

getColumnaAux(_,[],In,In).
getColumnaAux(Indice,[X|Xs],In,Out):-
    nth0(Indice,X,Elem),
    append(In,[Elem],Aux),
    getColumnaAux(Indice,Xs,Aux,Out).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% getFila(+N, +Matriz, -Fila).
%

% Retorna la fila ubicada en el Indice de la Matriz
getFila(N, Matriz, Fila) :-
    nth0(N, Matriz, Fila).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% noQuedanHashtags(+Lista)
%

% Verifica que no queden '#' en una lista.
noQuedanHashtags([]).
noQuedanHashtags([X|Xs]):-
   X \== "#",
   noQuedanHashtags(Xs).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% cantidadDeHashtagsIgualAPistas(+P, +Lista, -ListaRestante)
%

% Verifico que la lista cumpla con las pistas y devuelvo la lista restante sin los primeros # de la primera pista.
cantidadDeHashtagsIgualAPistas(0,[],[]).
cantidadDeHashtagsIgualAPistas(0, [Y|Ys], [Y|Ys]):-
   Y \== "#".
cantidadDeHashtagsIgualAPistas(P, [Y|Ys], Res):-
   Y == "#",
   Aux is P-1,
   cantidadDeHashtagsIgualAPistas(Aux, Ys, Res).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% recorrerHastaHashtag(+Lista, -ListaRes)
%

% Recorre la lista hasta llegar a un # y cuando llega retorna la lista restante.
recorrerHastaHashtag([], []).
recorrerHastaHashtag([X|Xs], [X|Xs]):-
   X == "#".
recorrerHastaHashtag([X|Xs], Res):-
   X \== "#",
   recorrerHastaHashtag(Xs, Res).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% verificarPistasEnLista(+P, +ListaRes)
%

% Verifica que se cumplan todas las pistas en la lista, devuleve true si se verifican y false en caso contrario.
verificarPistasEnLista([0], []).
verificarPistasEnLista([], Lista):-
   noQuedanHashtags(Lista).
verificarPistasEnLista([X|RestoPistas], Lista):-
    X == 0, 
    verificarPistasEnLista(RestoPistas, Lista). 
verificarPistasEnLista([X|RestoPistas], [Y|Ys]):-
   Y == "#",
   cantidadDeHashtagsIgualAPistas(X, [Y|Ys], Rta),
   ListaRestante = Rta,
   recorrerHastaHashtag(ListaRestante, LR),
   ListaReducidaHastaHashtag = LR,
   verificarPistasEnLista(RestoPistas, ListaReducidaHastaHashtag).
verificarPistasEnLista([X|RestoPistas], [Y|Ys]):-
    Y\== "#",
    recorrerHastaHashtag([Y|Ys], Respuesta),
    ListaEnHashtag = Respuesta,
    verificarPistasEnLista([X|RestoPistas], ListaEnHashtag).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% verificarFila(+LP, +ListaFila, -Resultado)
%

% Verifica que en la fila se cumplan las pistas, devuleve 1 si se verifica y 0 en caso contrario.
verificarFila(ListaPistas, ListaFila, 1):-
   verificarPistasEnLista(ListaPistas, ListaFila).
verificarFila(_ListaPistas, _ListaFila, 0).   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% verificarColumna(+LP, +ListaColumna, -Resultado)
%

% Verifica que en la columna se cumplan las pistas, devuleve 1 si se verifica y 0 en caso contrario.
verificarColumna(ListaPistas, ListaColumna, 1):-
   verificarPistasEnLista(ListaPistas, ListaColumna).
verificarColumna(_ListaPistas, _ListaColumna, 0).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% cantCol(+Matriz, -Resultado)
%

/* Retorna la cantidad columnas de una matriz */
cantCol([C|_], CantCol):-
   length(C, CantCol).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% cantFil(+Grilla, -Resultado)
%

/*Retorna la cantidad filas de una matriz */
cantFil(Grilla, CantFil):-
   length(Grilla, CantFil).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% verificarGrillaInicial(+Grilla, +PistasFilas, +PistasColumnas, +Aux, -ColumnasCumplen, -FilasCumplen).
%

% Recorre la grilla inicial del juego verificando si se cumplen o no las pistas, y retorna las filas y columnas en 
% las que efectivamente se verifican.
verificarGrillaInicial(Grilla, PistasFilas, PistasColumnas, Aux, ColumnasCumplen, FilasCumplen):-
   cantCol(Grilla, CC), 
   CantCol is CC, 
   verificarColumnasInicial(Grilla, PistasColumnas, Aux, CantCol, ColumnasCumplen),
   cantFil(Grilla, CF), 
   CantFil is CF, 
   verificarFilasInicial(Grilla, PistasFilas, Aux, CantFil, FilasCumplen).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% verificarColumnasInicial(+Grilla, +PistasColumnas, +Aux, +CantCol, -ColumnasCumplen)
%

% Recorre las columnas de la grilla inicial checkeando que se verifiquen las pistas. Retorna las columnas que las cumplen.
verificarColumnasInicial(_Grilla, _PistasColumnas, Aux, CantCol, []):-
    Aux == CantCol. 
verificarColumnasInicial(Grilla, PistasColumnas, Aux, CantCol, ColumnasCumplen):- 
   Aux < CantCol,   
   nth0(Aux, PistasColumnas, LPC), 
   ListaPistasColumna = LPC, 
   getColumna(Aux, Grilla, C), 
   Columna = C,
   Pos is Aux+1,
   (ColumnasCumplen = [Aux|RestoLista],
   verificarPistasEnLista(ListaPistasColumna, Columna)    
   ; 
   ColumnasCumplen = RestoLista), 
   verificarColumnasInicial(Grilla, PistasColumnas, Pos, CantCol, RestoLista).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% verificarFilasInicial(+Grilla, +PistasFilas, +Aux, +CantFil, -FilasCumplen)
%

% Recorre las filas de la grilla inicial checkeando que se verifiquen las pistas. Retorna las filas que las cumplen.
verificarFilasInicial(_Grilla, _PistasFilas, Aux, CantFilas, []):-
    Aux == CantFilas. 
verificarFilasInicial(Grilla, PistasFilas, Aux, CantFilas, FilasCumplen):-
   Aux<CantFilas,
   nth0(Aux, PistasFilas, LPF), 
   ListaPistasFila = LPF, 
   getFila(Aux, Grilla, F), 
   Fila = F,
   Pos is Aux+1,
   (FilasCumplen = [Aux|RestoLista],
   verificarPistasEnLista(ListaPistasFila, Fila)    
   ; 
   FilasCumplen = RestoLista), 
   verificarFilasInicial(Grilla, PistasFilas, Pos, CantFilas, RestoLista).

