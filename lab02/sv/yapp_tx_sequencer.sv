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

  // UVM Start of Simulation Phase
  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info("START_OF_SIM", $sformatf("Inside the start_of_simulation_phase of %s", get_type_name()), UVM_HIGH)
  endfunction : start_of_simulation_phase

endclass : yapp_tx_sequencer
