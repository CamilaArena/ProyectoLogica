import React from 'react';

class Clue extends React.Component {
    render() {
        const {clue} = this.props;
        const {satisfaction} = this.props;
        const {vertical} = this.props;

        return (
            <div className={(satisfaction ? " clueVerde" : " clueRoja") + (vertical ? " colClues" : " rowClues")} >
                {clue.map((num, i) =>
                    <div key={i}>
                        {num}
                    </div>
                )}
            </div>
        );
    }
}

export default Clue;