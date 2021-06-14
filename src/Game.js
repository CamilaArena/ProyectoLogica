import React from 'react';
import PengineClient from './PengineClient';
import Board from './Board';
import ToggleButton from './ToggleButton';

/*Toggle de dark mode*/
const checkbox = document.getElementById('checkbox');
checkbox.addEventListener('change', () => {
  document.body.classList.toggle('dark')
});

/* Boton de Resolver Nonograma */
const checkboxResolverNonograma = document.getElementById('checkboxResolverNonograma');
checkboxResolverNonograma.addEventListener('change', () => {
  console.log("llegue");
});
  
class Game extends React.Component {

  pengine;

  constructor(props) {
    super(props);
    this.state = {
      gridAux : null,
      grid: null,
      rowClues: null,
      colClues: null,
      selected: '#', //Modo de juego (X o #)
      disabled: false, //Deshabilita el tablero una vez que se gana el juego
      ganar: false,
      waiting: false,
      satisfaceF: false,
      satisfaceC: false,
      filaSatisface :[], 
      columnaSatisface:[],
      filasCumplen:[], 
      columnasCumplen:[], 
      statusText : '¡Bienvenido!',
      title : 'Nonograma', 
    };
    this.handleClick = this.handleClick.bind(this);
    this.handlePengineCreate = this.handlePengineCreate.bind(this);
    this.pengine = new PengineClient(this.handlePengineCreate);
  }

  handlePengineCreate() {

    const queryS = 'init(PistasFilas, PistasColumns, Grilla)';
    this.pengine.query(queryS, (success, response) => {
      if (success) {
        this.setState({
          grid: response['Grilla'],
          gridAux : response['Grilla'],
          rowClues: response['PistasFilas'],
          colClues: response['PistasColumns'],
          filaSatisface : Array(response['PistasFilas'].length),
          columnaSatisface : Array(response['PistasColumns'].length),
        });

        const tablero = JSON.stringify(this.state.grid).replaceAll('""', "");
        const queryInicial = 'verificarGrillaInicial(' + tablero + ', '+JSON.stringify(this.state.rowClues)+', '+JSON.stringify(this.state.colClues)+ ','+ 0 + ',ColumnasCumplen, FilasCumplen)';

        this.pengine.query(queryInicial, (success, response) => {
          if (success) {
            this.setState({
              filasCumplen : response['FilasCumplen'],
              columnasCumplen : response['ColumnasCumplen'],
            });
            this.setFilasyColumnasValidas();
            this.verificarGanar();
          }
        });
      }
    });
  }

  handleClick(i, j) {
    if (this.state.waiting) {
      return;
    }

    //PUT
    const squaresS = JSON.stringify(this.state.grid).replaceAll('""', "");
    const queryS = 'put("'+this.state.selected+'", [' + i + ',' + j + '], '+JSON.stringify(this.state.rowClues)+', '+JSON.stringify(this.state.colClues)+',' + squaresS + ', GrillaRes, FilaSat, ColSat)';
    this.setState({
      waiting: true
    });
  
    this.pengine.query(queryS, (success, response) => {
      if (success) {
        let nuevaGrilla = response['GrillaRes']; 
        let colSat = response['ColSat']; 
        let filaSat = response['FilaSat'];

        this.setState({
          grid: nuevaGrilla,
          satisfaceF: filaSat,
          satisfaceC: colSat,
        });
        
        this.filaValida(i, filaSat === 1);
        this.columnaValida(j, colSat === 1);
       
      } else {
        this.setState({
          waiting: false
        });
        
      }
          //Me fijo si gane el juego
          this.verificarGanar();
          if(this.state.ganar === true){
            this.setState({statusText:'Felicitaciones: ¡ganaste!'});
          }
          else{
             this.setState({statusText:'Continue jugando...'});
          }
    });
  }

  reiniciar(){
   /* this.setState ({grid: null});
    this.setState ({rowClues: null});
    this.setState ({colClues: null});
    this.setState ({selected: '#'}); //Modo de juego (X o #)
    this.setState ({disabled: false}); //Deshabilita el tablero una vez que se gana el juego
    this.setState ({ganar: false});
    this.setState ({waiting: false});
    this.setState ({satisfaceF: false});
    this.setState ({satisfaceC: false});
    this.setState ({filaSatisface : []}); 
    this.setState ({columnaSatisface: []});
    this.setState ({filasCumplen:[]});
    this.setState ({columnasCumplen: []}); 
    this.setState ({statusText : '¡Bienvenido!'});
    this.setState ({title : 'Nonograma'});*/

    this.setState({
      grid : [...this.state.gridAux] 
    });
  
   /* this.handleClick = this.handleClick.bind(this);
    this.handlePengineCreate = this.handlePengineCreate.bind(this);*/
   /*  this.handlePengineCreate(); //Inicia una nueva partida*/
  }



  /*Cambia el modo de juego (pasa de # a X, o X a #)*/
  cambiarModo() {
    var nModo = 'X';
    if (this.state.selected === 'X') {
      nModo = '#';
    }
    this.setState({
      selected: nModo,
    }) 
  }

  /* Dado un indice correspondiente a una fila, asigna en la posicion index de filaSatisface, un 1 o 0 dependiendo si
    esa fila satisface o no las propiedades */
  filaValida(index, cumple){
    let auxiliar= [...this.state.filaSatisface];
    auxiliar[index]=cumple;
    this.setState({filaSatisface:auxiliar,waiting:false});
  }

  /* Dado un indice correspondiente a una columna, asigna en la posicion index de columnaSatisface, un 1 o 0 dependiendo si
    esa columna satisface o no las propiedades */
    columnaValida(index, cumple){
    let auxiliar = [...this.state.columnaSatisface]; 
    auxiliar[index] = cumple;
    this.setState({columnaSatisface:auxiliar, waiting: false});
  }

  /* Se recorren las filas y columnas de la grilla poniendo en “1” o “0” el estado de filasCumplen y columnasCumplen 
    respectivamente, para poder verificar qué filas y columnas cumplen las condiciones al inicio del juego */
    setFilasyColumnasValidas(){
    for(var i = 0; i<this.state.filasCumplen.length; i++){
      this.filaValida(this.state.filasCumplen[i],1);
     }
  
     for(var j = 0; j<this.state.columnasCumplen.length; j++){
       this.columnaValida(this.state.columnasCumplen[j],1);
     }
   }

  /* Verifica si se ha ganado la partida del Nonograma */
  verificarGanar(){
    var verificaF = true;   
    var verificaC = true;
    /* Checkeo la lista de pistas de las filas */
    for(var fila = 0; fila<this.state.filaSatisface.length && verificaF; fila++){
      if(this.state.filaSatisface[fila] === undefined || this.state.filaSatisface[fila] === false){
        verificaF = false;
      }
    }

    /* Checkeo la lista de pistas de las columnas */
    for(var col = 0; col<this.state.columnaSatisface.length && verificaC; col++){
      if(this.state.columnaSatisface[col] === undefined || this.state.columnaSatisface[col] === false){
         verificaC = false;
      }
    }

    if(verificaC && verificaF){
      this.setState({ganar : true, disabled:true,});
    }
    else{
      this.setState({ganar : false,});
    }
  }

  render() {
    if (this.state.grid === null) {
      return null;
    }

    /* Boton de ayuda */
    const help = document.querySelector('.botonAyuda');
     help.addEventListener('click', () => {

     const tablero = JSON.stringify(this.state.grid).replaceAll('""', "");
     const queryResolver = 'resolverNonograma(' + tablero + ', '+JSON.stringify(this.state.rowClues)+', '+JSON.stringify(this.state.colClues)+ ',' +'grillaResuelta )';

      /*resolverNonograma(GrillaIn, PistasFila, PistasCol, GrillaFinal)*/    
      
     this.pengine.query(queryResolver, (success, response) => {
      if (success) {
        this.setState({
          grid: response['grillaResuelta'],
       });
      }
    });
   });




    /* Boton restart */
    const btn = document.querySelector('.restart-button');
    btn.addEventListener('click', () => {
      window.location.reload(false);
    });

        
    return (
      <div className = "game">
        <div className = "titulo">
        {this.state.title}
        </div>
        <Board
          grid = {this.state.grid}
          rowClues = {this.state.rowClues}
          colClues = {this.state.colClues}
          onClick = {(i, j) => this.handleClick(i,j)}
          filaSatisface = {this.state.filaSatisface}
          columnaSatisface = {this.state.columnaSatisface}
          disabled = {this.state.disabled}
        />

        <div className = "gameInfo">
          {this.state.statusText}
        </div>
     
        <ToggleButton
          onClick={() => this.cambiarModo()}
          selected = {this.state.selected}/>
        </div>
    );
  }
}

export default Game;