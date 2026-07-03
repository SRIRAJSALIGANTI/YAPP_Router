//------------------------------------------------------------------------------
// Component: yapp_tx_sequencer
// Description: Controls transaction stream flow from sequences to the driver
//------------------------------------------------------------------------------

class yapp_tx_sequencer extends uvm_sequencer #(yapp_packet);

  // Register the sequencer with the UVM Factory to enable type overrides
  `uvm_component_utils(yapp_tx_sequencer)

  //----------------------------------------------------------------------------
  // Constructor: new
  // Standard initialization for UVM component hierarchy tree creation
  //----------------------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : yapp_tx_sequencer
