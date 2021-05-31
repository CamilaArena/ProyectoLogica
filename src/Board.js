import React from 'react';
import Square from './Square';
import Clue from './Clue';


class Board extends React.Component {
    render() {
        const numOfRows = this.props.grid.length;
        const numOfCols = this.props.grid[0].length;
        const rowClues = this.props.rowClues;
        const colClues = this.props.colClues;
        const filaSatisface=this.props.filaSatisface;
        const columnaSatisface=this.props.columnaSatisface;
        const disabled = this.props.disabled; //Deshabilita el tablero
      
        return (
            <div className="vertical">
                <div
                    className="colClues"
                    style={{
                        gridTemplateRows: '60px',
                        gridTemplateColumns: '60px repeat(' + numOfCols + ', 40px)'
                        /*
                           60px  40px 40px 40px 40px 40px 40px 40px   (gridTemplateColumns)
                          _ _ _ _ _ _ _ _
                         |      |    |    |    |    |    |    |    |  60px
                         |      |    |    |    |    |    |    |    |  (gridTemplateRows)
                          ------ ---- ---- ---- ---- ---- ---- ---- 
                         */
                    }}
                >
                    <div>{/* top-left corner square */}</div>
                    {colClues.map((clue, i) =>
                        <Clue clue={clue} key={i} vertical = {true} satisfaction={columnaSatisface[i]} index={i}/>
                    )}
                </div>
                <div className="horizontal">
                    <div
                        className="rowClues"
                        style={{
                            gridTemplateRows: 'repeat(' + numOfRows + ', 40px)',
                            gridTemplateColumns: '60px'
                            /* IDEM column clues above */
                        }}
                    >
                        {rowClues.map((clue, i) =>
                             <Clue clue={clue} key={i} vertical = {false} satisfaction={filaSatisface[i]} index={i}/> 
                        )}
                    </div>
                    <div className="board"
                        style={{
                            gridTemplateRows: 'repeat(' + numOfRows + ', 40px)',
                            gridTemplateColumns: 'repeat(' + numOfCols + ', 40px)'
                        }}>
                            
                        {this.props.grid.map((row, i) =>
                            row.map((cell, j) =>
                                <Square
                                    disabled = {disabled}
                                    value={cell}
                                    onClick={() => this.props.onClick(i, j)}
                                    key={i + j}
                                />
                            )
                        )}
                    </div>
                </div>
            </div>
        );
    }
}

export default Board;