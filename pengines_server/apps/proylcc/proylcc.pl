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

   nth0(RowN, NewGrilla, ListaFila), %Obtengo la fila

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
   nth0(Aux, Grilla, F), 
   Fila = F,
   Pos is Aux+1,
   (FilasCumplen = [Aux|RestoLista],
   verificarPistasEnLista(ListaPistasFila, Fila)    
   ; 
   FilasCumplen = RestoLista), 
   verificarFilasInicial(Grilla, PistasFilas, Pos, CantFilas, RestoLista).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% rellenarConX(+Lista)
%

% Dada una lista, le inserta "X" hasta el final.
rellenarConX([]).
rellenarConX([X|Xs]):-
   X = "X",
   rellenarConX(Xs).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% generarHashtagsIgualAPistas(+P, +Lista, -ListaRestante)
%

% Genera una lista con P "#" y luego inserta una "X".
generarHashtagsIgualAPistas(0,[],[]).
generarHashtagsIgualAPistas(0, [Y|Ys], [Y|Ys]):-
   Y = "X".
generarHashtagsIgualAPistas(P, [Y|Ys], Res):-
   Y = "#",
   Aux is P-1,
   generarHashtagsIgualAPistas(Aux, Ys, Res).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% predicadoAux(+Lista, -ListaRes)
%

% 
predicadoAux([], []).
predicadoAux([X|Xs], [X|Xs]):-
   X = "#".
predicadoAux([X|Xs], Res):-
   X = "X",
   predicadoAux(Xs, Res).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% generarListaConPistas(+P, +ListaRes)
%

% Dada una lista de pistas, genera una fila que verifica las pistas dadas.
% Si no existe una fila que verifique las pistas retorna falso.
generarListaConPistas([0], []).
generarListaConPistas([], Lista):-
   rellenarConX(Lista).
generarListaConPistas([X|RestoPistas], Lista):-
    X == 0, 
    generarListaConPistas(RestoPistas, Lista). 
generarListaConPistas([X|RestoPistas], [Y|Ys]):-
   Y = "#",
   generarHashtagsIgualAPistas(X, [Y|Ys], Rta),
   ListaRestante = Rta,
   predicadoAux(ListaRestante, LR),
   ListaReducidaHastaHashtag = LR,
   generarListaConPistas(RestoPistas, ListaReducidaHastaHashtag).
generarListaConPistas([X|RestoPistas], [Y|Ys]):-
    Y = "X",
    predicadoAux([Y|Ys], Respuesta),
    ListaEnHashtag = Respuesta,
    generarListaConPistas([X|RestoPistas], ListaEnHashtag).





/*Primera pasada: Es para las filas/col que podemos asegurar 1 sola movida
suma_pistas + length_pistas - 1 == Long de fila o columna*/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sumarPistas(+P, +Suma)
%

% Dada una lista de pistas, retorna la suma total de la lista de pistas.
sumarPistas([], 0).
sumarPistas([X|Xs], Suma):-
          sumarPistas(Xs, SumaAux),
          Suma is SumaAux + X.


listasSeguras(_GrillaIn, _PistasFila, Aux, Cant, []):- 
    Aux == Cant.   %Si Aux == cantFilas significa que ya recorri todas las filas de la grilla
listasSeguras(GrillaIn, ListaPistas, Aux, Cant, [ListaSegura|RestoSalida]):-
    Aux < Cant,
    nth0(Aux, GrillaIn, Lista), %Obtengo la fila en la posicion Aux de la grilla
    length(Lista, LongitudLista),
	nth0(Aux, ListaPistas, Pista), %Obtengo las pistas de la fila en la posicion Aux de la grilla
	sumarPistas(Pista, Suma),
    length(Pista, LongitudPista),
    Cuenta is (Suma + LongitudPista-1), %Cuenta calcula si la fila que cumple con las pistas tiene una unica solucion
    Cuenta == LongitudLista, %Verifico que la fila tenga una unica solucion
    generarListaConPistas(Pista, ListaSegura), %Si la fila es unica, entonces genero la fila segura
    Aux2 is Aux+1, %Aumento Aux para pasar a la siguiente fila
    listasSeguras(GrillaIn, ListaPistas, Aux2, Cant, RestoSalida).
listasSeguras(GrillaIn, ListaPistas, Aux, Cant, [Lista|RestoSalida]):-
    Aux < Cant,
    nth0(Aux, GrillaIn, Lista), %Obtengo la fila en la posicion Aux de la grilla
    Aux2 is Aux+1, %Aumento Aux para pasar a la siguiente fila
    listasSeguras(GrillaIn, ListaPistas, Aux2, Cant, RestoSalida).

    
    
resolverNonograma(GrillaIn, PistasFila, PistasCol, GrillaFinal):-
	%Primera parte del algoritmo
	cantFil(GrillaIn, CantFilas),
    listasSeguras(GrillaIn, PistasFila, 0, CantFilas, GrillaAuxiliarF),
   transpose(GrillaAuxiliarF, Transpuesta),
    cantCol(GrillaIn, CantCol),
    listasSeguras(Transpuesta, PistasCol, 0, CantCol, GrillaAuxiliarC),
    transpose(GrillaAuxiliarC, GrillaDeNuevo),
    %Segunda parte del algoritmo
    resolucionCompleta(GrillaDeNuevo, PistasFila, PistasCol, GrillaFinal, CantFilas, CantCol).

resolucionCompleta(_GrillaDeNuevo, _PistasFila, _PistasCol, GrillaFinal, _CantFilas, _CantCol):-
    forall(member(L, GrillaFinal), (forall(member(X, L), not(var(X))))).  
resolucionCompleta(GrillaDeNuevo, PistasFila, PistasCol, GrillaFinal, CantFilas, CantCol):-
    segundaParte(GrillaDeNuevo, PistasFila, PistasCol, GrillaDeNuevo, CantFilas, CantCol), 
    pasadaFinal(GrillaDeNuevo, PistasFila, PistasCol, GrillaFinal,CantCol). 
resolucionCompleta(GrillaDeNuevo, PistasFila, PistasCol, GrillaFinal, CantFilas, CantCol):-
	segundaParte(GrillaDeNuevo, PistasFila, PistasCol, GrillaAux, CantFilas, CantCol),
    resolucionCompleta(GrillaAux, PistasFila, PistasCol, GrillaFinal, CantFilas, CantCol). 
    
/*segundaParte(GrillaIn, PistasFilas, PistasCol, GrillaFinal, CantFilas, CantCol):-
    allAtomico(GrillaFinal). */
segundaParte(GrillaIn, PistasFilas, PistasCol, GrillaFinal, CantFilas, CantCol):-
    generarListasFinales(GrillaIn, PistasFilas, CantFilas, GrillaAuxiliarFilas, 0, CantCol),
    transpose(GrillaAuxiliarFilas, Transpuesta),
    generarListasFinales(Transpuesta, PistasCol, CantCol, GrillaFinalAuxCol, 0, CantFilas), 
    transpose(GrillaFinalAuxCol, GrillaFinal).


generarListasFinales(_GrillaIn, _ListaPistas, Cant, [], Aux, _Length):-
    Aux == Cant. 
generarListasFinales(GrillaIn, ListaPistas, Cant, [ListaFinal | RestoSalida], Aux, Length):-
    Aux < Cant,
    nth0(Aux, GrillaIn, Lista), 
    not(listaLlena(Lista)),  
	nth0(Aux, ListaPistas, Pista),
    findall(Lista, (length(Lista, Length), generarListaConPistas(Pista, Lista)), TodasPosibles), 
    interseccion(TodasPosibles, Cant, 0, ListaFinal), 
    Aux2 is Aux+1, 
    generarListasFinales(GrillaIn, ListaPistas, Cant, RestoSalida, Aux2, Length).
generarListasFinales(GrillaIn, ListaPistas, Cant, [Lista | RestoSalida], Aux, Length):-
    Aux < Cant,
    nth0(Aux, GrillaIn, Lista), 
    Aux2 is Aux+1, 
   	generarListasFinales(GrillaIn, ListaPistas, Cant, RestoSalida, Aux2, Length).     




interseccion(TodasPosibles, CantFilas, Aux, Out):-
    interseccion_aux(TodasPosibles, CantFilas, Aux, [], Out).


interseccion_aux(_TodasPosibles, CantFilas, CantFilas, Out, Out).
interseccion_aux(TodasPosibles, CantFilas, Aux, In, Out):-
   	Aux < CantFilas, 
    findall(Elemento, (member(Lista, TodasPosibles), nth0(Aux, Lista, Elemento)), TodosLosElementos), 
    todosIguales("#", TodosLosElementos), 
   	append(In, ["#"], ListaAuxiliar),
    Aux2 is Aux+1, 
    interseccion_aux(TodasPosibles, CantFilas, Aux2, ListaAuxiliar, Out). 
interseccion_aux(TodasPosibles, CantFilas, Aux, In, Out):-
  	Aux < CantFilas, 
    findall(Elemento, (member(Lista, TodasPosibles), nth0(Aux, Lista, Elemento)), TodosLosElementos), 
    todosIguales("X", TodosLosElementos), 
  	append(In, ["X"], ListaAuxiliar),
    Aux2 is Aux+1, 
    interseccion_aux(TodasPosibles, CantFilas, Aux2, ListaAuxiliar, Out). 
interseccion_aux(TodasPosibles, CantFilas, Aux, In, Out):-
    Aux < CantFilas, 
   	append(In,[_], ListaAuxiliar),
    Aux2 is Aux+1, 
    interseccion_aux(TodasPosibles, CantFilas, Aux2, ListaAuxiliar, Out). 
    

todosIguales(_Elemento, []). 
todosIguales(Elemento, [X|Xs]):-
    X == Elemento, 
    todosIguales(Elemento, Xs). 
    

listaLlena([]).     
listaLlena([X|Xs]):-
    X == "#", 
    listaLlena(Xs). 
listaLlena([X|Xs]):-
    X == "X",
    listaLlena(Xs).


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






pasadaFinal(GrillaIn, PistasFila, PistasCol, GrillaOut, CantCol):-
    pasadaFinalAux(GrillaIn, PistasFila, PistasCol, [], GrillaOut, CantCol). 

pasadaFinalAux([], _PistasFila, PistasCol, Acumulado, Acumulado, CantCol):-
    verificarColumnasInicial(Acumulado, PistasCol, 0, CantCol, ColumnasCumplen), 
    length(ColumnasCumplen, L), 
    L == CantCol. 
pasadaFinalAux([Fila|RestoGrilla], [_|RestoPistasFila], PistasCol, Acumulado, GrillaOut, _CantCol):-
    listaLlena(Fila), 
    append(Acumulado, [Fila], Aux2), 
    pasadaFinalAux(RestoGrilla, RestoPistasFila, PistasCol, Aux2, GrillaOut, _CantCol).
pasadaFinalAux([Fila|RestoGrilla], [Pista|RestoPistasFila], PistasCol, Acumulado, GrillaOut, _CantCol):-
    generarListaConPistas(Pista, Fila), 
    append(Acumulado, [Fila], Aux2), 
    pasadaFinalAux(RestoGrilla, RestoPistasFila, PistasCol, Aux2, GrillaOut, _CantCol). 
    