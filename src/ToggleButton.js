import React from "react";

class ToggleButton extends React.Component {
  render() {
    return ( 
      <div className="modojuego">
        <input
          type="checkbox"
          className="toggle-switch-checkbox"
          name="toggleSwitch"
          id="toggleSwitch"
          onChange={this.props.onClick}
        />
        <label className="labelModoJuego" htmlFor="toggleSwitch">
          <i className="fa fa-window-close fa-2x" aria-hidden="true"></i>
          <i className="fa fa-square fa-2x" aria-hidden="true"></i>
          <div className="ballModoJuego"></div>
        </label>
      </div>
    );
  }
}

export default ToggleButton;
