//------------------------------------------------------------------------------
// Component: yapp_env
// Description: Top-level environment container that aggregates all UVCs 
//              (agents, scoreboards, coverage collectors) for the YAPP block.
//------------------------------------------------------------------------------

class yapp_env extends uvm_env;

  // Register the environment component with the UVM Factory
  `uvm_component_utils(yapp_env)

  // Handle for the transmitter sub-agent component
  yapp_tx_agent agent;

  //----------------------------------------------------------------------------
  // Constructor: new
  // Standard UVM component constructor to define structural hierarchy name
  //----------------------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //----------------------------------------------------------------------------
  // Phase: build_phase
  // Allocates memory and constructs child verification components
  //----------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Factory creation of the transmitter agent component
    agent = yapp_tx_agent::type_id::create("agent", this);
  endfunction : build_phase

  //----------------------------------------------------------------------------
  // Task: run_phase
  // Main simulation phase where stimulus is processed and structural printing occurs
  //----------------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    // Lab 2 Requirement: Print the environment instance details.
    // Calling print() on a container displays its entire nested sub-topology.
    this.print();
  endtask : run_phase

endclass : yapp_env

