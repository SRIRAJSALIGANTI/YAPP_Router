//------------------------------------------------------------------------------
// Component: yapp_tx_agent
// Description: Container component that encapsulates the sequencer, driver, 
//              and monitor for the YAPP Transmitter UVC.
//------------------------------------------------------------------------------

class yapp_tx_agent extends uvm_agent;

  // Register the agent component with the UVM Factory
  `uvm_component_utils(yapp_tx_agent)

  // Component handles within this structural block
  yapp_tx_monitor   monitor;
  yapp_tx_driver    driver;
  yapp_tx_sequencer sequencer;

  // Note: 'is_active' property is automatically inherited from the uvm_agent 
  // base class and defaults to UVM_ACTIVE. No local redeclaration is needed.

  //----------------------------------------------------------------------------
  // Constructor: new
  // Initializes the agent component within the UVM verification hierarchy tree
  //----------------------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //----------------------------------------------------------------------------
  // Phase: build_phase
  // Instantiates sub-components based on active/passive configuration settings
  //----------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Monitor is passive and always present regardless of agent operating mode
    monitor = yapp_tx_monitor::type_id::create("monitor", this);

    // Conditionally instantiate stimulus components if the agent is marked ACTIVE
    if (is_active == UVM_ACTIVE) begin
      driver    = yapp_tx_driver::type_id::create("driver", this);
      sequencer = yapp_tx_sequencer::type_id::create("sequencer", this);
    end
  endfunction : build_phase

  //----------------------------------------------------------------------------
  // Phase: connect_phase
  // Cross-connects internal TLM ports between sub-components
  //----------------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Hook up driver-sequencer interface channel only if components were built
    if (is_active == UVM_ACTIVE) begin
      // Binds driver sequence item request port to sequencer's arbitration export
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction : connect_phase

  // UVM Start of Simulation Phase
  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info("START_OF_SIM", $sformatf("Inside the start_of_simulation_phase of %s", get_type_name()), UVM_HIGH)
  endfunction : start_of_simulation_phase

endclass : yapp_tx_agent
