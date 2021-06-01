import React from 'react';

class Square extends React.Component {
    disabled = this.props.disabled; //Deshabilita el square
    
    render() {
        let classN = (this.props.value === '#' ? 'fondo' : 'square');
        return (
            <button className={classN} onClick={this.props.onClick} disabled={this.props.disabled}>
                {this.props.value === 'X' ? this.props.value : null}
            </button>
        );
    }
}

export default Square;