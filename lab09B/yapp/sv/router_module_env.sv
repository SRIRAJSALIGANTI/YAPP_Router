//------------------------------------------------------------------------------
// Component: router_module_env
// Description: Wrapper environment containing the scoreboard and reference components.
//------------------------------------------------------------------------------

class router_module_env extends uvm_env;

  // Register component with the UVM factory
  `uvm_component_utils(router_module_env)

  // a. Declare the scoreboard and router reference components
  router_scoreboard scoreboard;
  router_reference  reference;

  //----------------------------------------------------------------------------
  // Constructor
  //----------------------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //----------------------------------------------------------------------------
  // a. Build Phase: Instantiate the components using the factory
  //----------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    scoreboard = router_scoreboard::type_id::create("scoreboard", this);
    reference  = router_reference::type_id::create("reference", this);
  endfunction : build_phase

  //----------------------------------------------------------------------------
  // b. Connect Phase: Connect the reference model output to the scoreboard
  //----------------------------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect the valid YAPP analysis port of the reference model 
    // to the YAPP analysis imp of the scoreboard model.
    reference.reference_out.connect(scoreboard.yapp_in);
  endfunction : connect_phase

endclass : router_module_env
