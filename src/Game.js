import React from 'react';
import PengineClient from './PengineClient';
import Board from './Board';
import ToggleButton from './ToggleButton';

/*Toggle de dark mode*/
const checkbox = document.getElementById('checkbox');
checkbox.addEventListener('change', () => {
  document.body.classList.toggle('dark')
});
  
class Game extends React.Component {

  pengine;

  constructor(props){
    super(props);
    this.state = {
      grillaResuelta : null,
      grid: null,
      rowClues: null,
      grilla_a_mostrar: null,
      colClues: null,
      selected: '#', //Modo de juego (X o #)
      disabled: false, //Deshabilita el tablero una vez que se gana el juego
      ganar: false,
      waiting: false,
      satisfaceF: false,
      satisfaceC: false,
      mostrarSolucion: false,
      ayuda : false,
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

  
  showCelda() {
    if (this.state.ayuda === false) {
      this.setState({
        ayuda: true,
      })
    }
    else {
      this.setState({
        ayuda: false,
      })
    }
  }

  /* Muestra la solucion del Nonograma en la grilla del juego*/
  resolverNonograma() {
    if (this.state.mostrarSolucion === false) {  
      this.setState({
        mostrarSolucion: true,
      })
    }
    else {
      this.setState({
        mostrarSolucion: false,
      })
    }
  }

  handlePengineCreate() {

    const queryS = 'init(PistasFilas, PistasColumns, Grilla)';
    this.pengine.query(queryS, (success, response) => {
      if (success) {
        const grid = response['Grilla'];
        this.setState({
          grid: grid,
          gridAux : response['Grilla'],
          rowClues: response['PistasFilas'],
          colClues: response['PistasColumns'],
          filaSatisface : Array(response['PistasFilas'].length),
          columnaSatisface : Array(response['PistasColumns'].length),
        });
        
        const tablero = JSON.stringify(grid).replaceAll('"_"', '_');
        const queryInicial = 'verificarGrillaInicial(' + tablero + ', '+JSON.stringify(this.state.rowClues)+', '+JSON.stringify(this.state.colClues)+ ','+ 0 + ',ColumnasCumplen, FilasCumplen)';

        this.pengine.query(queryInicial, (success, response) => {
          if (success) {
            this.setState({
              filasCumplen : response['FilasCumplen'],
              columnasCumplen : response['ColumnasCumplen'],
            });
            this.setFilasyColumnasValidas();
           
          //Me fijo si gane el juego por si ingresaron una grilla resuelta
          this.verificarGanar();
          if(this.state.ganar === true){
            this.setState({statusText:'Felicitaciones: ¡ganaste!'});
          }
          }
        });

        const queryResolver = 'resolverNonograma(' + tablero + ', '+JSON.stringify(this.state.rowClues)+', '+JSON.stringify(this.state.colClues)+',GrillaResuelta )';
   
        this.pengine.query(queryResolver, (success, response) => {
          if (success) {
            this.setState({
              grillaResuelta: response['GrillaResuelta'],
            });
          }
        });
      }
    });
  }

  handleClick(i, j) {
    if (this.state.waiting ) {
      return;
    }

      const celda_a_insertar = this.state.grillaResuelta[i][j];  //Se recupera la celda [i][j] de la grilla resuelta.
      const elem = this.state.ayuda ? celda_a_insertar : this.state.selected;

    if (this.state.grid[i][j] === "_") {    //Se revela una celda si y solo sí esta se encuentra en blanco

      //PUT
      const squaresS = JSON.stringify(this.state.grid).replaceAll('""', "");
      const queryS = 'put("'+elem+'", [' + i + ',' + j + '], '+JSON.stringify(this.state.rowClues)+', '+JSON.stringify(this.state.colClues)+',' + squaresS + ', GrillaRes, FilaSat, ColSat)';
      this.setState({
        ayuda: false,
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
           this.setState({statusText:'Continúe jugando . . .'});
        }
      });
      
    }
    else{
      
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
        
        } 
        else {
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
           this.setState({statusText:'Continúe jugando . . .'});
        }
      });
    }
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

    let botonAyudaOFF = (this.state.ayuda ? 'botonAyudaON' : 'botonAyudaOFF'); 
    
    return (
      <div className = "game">

        <div className = "titulo">
        {this.state.title}
        </div>

        <Board
          grid = {this.state.mostrarSolucion ? this.state.grillaResuelta : this.state.grid}
          rowClues = {this.state.rowClues}
          colClues = {this.state.colClues}
          onClick = {(i, j) => this.handleClick(i,j)}
          filaSatisface = {this.state.filaSatisface}
          columnaSatisface = {this.state.columnaSatisface}
          disabled = {this.state.disabled}
        />

          <div className = "SeccionAyuda">
            <div>
                <input type = "checkbox" className = "checkboxResolverNonograma" id = "checkboxResolverNonograma" onChange = {() => this.resolverNonograma()} value = {this.state.mostrarSolucion} ></input>
                  <label htmlFor = "checkboxResolverNonograma" className = "labelResolverNonograma">
                    <i className ="fa fa-question" aria-hidden="true"></i>
                    <div className = "ballResolverNonograma"></div>
                  </label>   
            </div> 
          </div> 

          <div>
              <button className = {botonAyudaOFF} onClick = {() => {
                this.showCelda()
                }}></button>
          </div>

    
       <div className = "SeccionControles">
          <div>
            <button className ="restart-button"  onClick = {() =>  window.location.reload(false)}><i className="fas fa-sync-alt fa-2x"></i></button>
          </div>   

          <div>
            <ToggleButton
              onClick={() => this.cambiarModo()}
              selected = {this.state.selected}/>
          </div>
       </div>
      
       <div className = "gameInfo">
              {this.state.statusText}
       </div>

      </div>
    );
  }
}

export default Game;