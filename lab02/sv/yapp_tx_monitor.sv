//------------------------------------------------------------------------------
// Component: yapp_tx_monitor
// Description: Passive component that samples the DUT signals to capture packets
//------------------------------------------------------------------------------

class yapp_tx_monitor extends uvm_monitor;

  // Register the monitor with the UVM Factory
  `uvm_component_utils(yapp_tx_monitor)

  //----------------------------------------------------------------------------
  // Constructor: new
  // Allocates memory and attaches component to the target verification topology
  //----------------------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //----------------------------------------------------------------------------
  // Task: run_phase
  // Automatically called by the phase controller to execute parallel monitoring
  //----------------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    // Lab requirement: Simple tracking check to confirm initialization
    `uvm_info("MON_RUN", "Inside the run_phase of yapp_tx_monitor", UVM_LOW)
    
    // Note: In later labs (Lab 6+), you will add a forever loop here 
    // to sample the physical virtual interface pins and reconstruct packets.
  endtask : run_phase

  // UVM Start of Simulation Phase
  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info("START_OF_SIM", $sformatf("Inside the start_of_simulation_phase of %s", get_type_name()), UVM_HIGH)
  endfunction : start_of_simulation_phase

endclass : yapp_tx_monitor
