//------------------------------------------------------------------------------
// Component: router_tb
// Description: Top-level verification testbench container holding the YAPP 
//              environment, three Channel UVCs, and the HBUS UVC.
//------------------------------------------------------------------------------

class router_tb extends uvm_component;

  yapp_env env;

  channel_env chan0;
  channel_env chan1;
  channel_env chan2;

  // a. Add a handle for the HBUS UVC
  hbus_env hbus;

  `uvm_component_utils(router_tb)

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

    // b. Configure HBUS to only instantiate the Master agent
    set_config_int("hbus", "num_masters", 1);
    set_config_int("hbus", "num_slaves", 0);

    set_config_int("*", "recording_detail", 1);
    
    super.build_phase(phase);

    env = yapp_env::type_id::create("env", this);

    chan0 = channel_env::type_id::create("chan0", this);
    chan1 = channel_env::type_id::create("chan1", this);
    chan2 = channel_env::type_id::create("chan2", this);

    // a. Create the HBUS UVC instance using a factory call
    hbus = hbus_env::type_id::create("hbus", this);

    `uvm_info("TB_BUILD", "router_tb build_phase executed: yapp_env, 3 channel_envs, and hbus_env instantiated.", UVM_HIGH)
  endfunction : build_phase

endclass : router_tb
