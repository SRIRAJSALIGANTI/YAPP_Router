//------------------------------------------------------------------------------
// Component: router_tb
// Description: Top-level verification testbench container holding the YAPP 
//              environment, three Channel UVCs, the HBUS UVC, the Virtual Sequencer,
//              and the router module environment wrapper.
//------------------------------------------------------------------------------

class router_tb extends uvm_component;

  `uvm_component_utils(router_tb)

  // Existing UVC environment handles
  yapp_env env;

  channel_env chan0;
  channel_env chan1;
  channel_env chan2;

  hbus_env hbus;

  // New: Add a handle for the Virtual Sequencer
  router_virtual_sequencer v_sqr;
  
  // a. Replace the scoreboard declaration with the router module environment
  router_module_env router_mod;

  //----------------------------------------------------------------------------
  // Constructor: new
  //----------------------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //----------------------------------------------------------------------------
  // Function: build_phase
  //----------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    // Channel configuration
    set_config_int("chan0", "has_tx", 0);
    set_config_int("chan1", "has_tx", 0);
    set_config_int("chan2", "has_tx", 0);

    // Configure HBUS to only instantiate the Master agent
    set_config_int("hbus", "num_masters", 1);
    set_config_int("hbus", "num_slaves", 0);

    set_config_int("*", "recording_detail", 1);
    
    super.build_phase(phase);

    // Instantiate existing UVC environments
    env   = yapp_env::type_id::create("env", this);
    chan0 = channel_env::type_id::create("chan0", this);
    chan1 = channel_env::type_id::create("chan1", this);
    chan2 = channel_env::type_id::create("chan2", this);
    hbus  = hbus_env::type_id::create("hbus", this);

    // New: Create the Virtual Sequencer instance using the UVM factory
    v_sqr = router_virtual_sequencer::type_id::create("v_sqr", this);

    // a. Replace the scoreboard build with the router module environment factory creation
    router_mod = router_module_env::type_id::create("router_mod", this);

    `uvm_info("TB_BUILD", "router_tb build_phase executed: UVC environments and v_sqr instantiated.", UVM_HIGH)
  endfunction : build_phase

  //----------------------------------------------------------------------------
  // Function: connect_phase
  //----------------------------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // 1. Connect the YAPP sub-sequencer handle
    v_sqr.yapp_seqr = env.agent.sequencer;

    // 2. Connect the HBUS master sub-sequencer handle (first master agent)
    v_sqr.hbus_seqr = hbus.masters[0].sequencer;

    // b. Modify the TLM connections for YAPP and Channels to target the new router_mod layer
    // Connect YAPP Monitor to the reference model input inside the router module layer
    env.agent.monitor.item_collected_port.connect(router_mod.reference.yapp_in);

    // Connect individual passive Channel Monitors to the scoreboard inputs inside the router module layer
    chan0.rx_agent.monitor.item_collected_port.connect(router_mod.scoreboard.chan0_out);
    chan1.rx_agent.monitor.item_collected_port.connect(router_mod.scoreboard.chan1_out);
    chan2.rx_agent.monitor.item_collected_port.connect(router_mod.scoreboard.chan2_out);

    // c. Add a connection for the HBUS analysis port to feed the reference model
    hbus.masters[0].monitor.item_collected_port.connect(router_mod.reference.hbus_in);

    `uvm_info("TB_CONNECT", "router_tb connect_phase executed: Virtual Sequencer and router_mod layer connected.", UVM_HIGH)
  endfunction : connect_phase

endclass : router_tb
