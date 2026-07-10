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

  // Handle for the Virtual Sequencer
  router_virtual_sequencer v_sqr;
  
  // Router module environment layer
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

    // Create the Virtual Sequencer instance using the UVM factory
    v_sqr = router_virtual_sequencer::type_id::create("v_sqr", this);

    // Create the router module environment wrapper
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

    // UPDATED: Modify TLM connections to use the surface exports of router_mod
    // Connect YAPP Monitor to the router module environment's YAPP export
    env.agent.monitor.item_collected_port.connect(router_mod.yapp_in);

    // Connect HBUS analysis port to the router module environment's HBUS export
    hbus.masters[0].monitor.item_collected_port.connect(router_mod.hbus_in);

    // Connect individual passive Channel Monitors to the router module environment's Channel exports
    chan0.rx_agent.monitor.item_collected_port.connect(router_mod.chan0_in);
    chan1.rx_agent.monitor.item_collected_port.connect(router_mod.chan1_in);
    chan2.rx_agent.monitor.item_collected_port.connect(router_mod.chan2_in);

    `uvm_info("TB_CONNECT", "router_tb connect_phase executed: Virtual Sequencer and router_mod layer connected.", UVM_HIGH)
  endfunction : connect_phase

endclass : router_tb
