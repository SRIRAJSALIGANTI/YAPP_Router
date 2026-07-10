//------------------------------------------------------------------------------
// Component: router_module_env
// Description: Wrapper environment containing the scoreboard and reference components.
//              Updated to encapsulate internal connections using analysis exports.
//------------------------------------------------------------------------------

class router_module_env extends uvm_env;

  // Register component with the UVM factory
  `uvm_component_utils(router_module_env)

  // Declare the scoreboard and router reference components
  router_scoreboard scoreboard;
  router_reference  reference;

  // NEW: Declare top-level analysis export objects
  uvm_analysis_export #(yapp_packet)      yapp_in;
  uvm_analysis_export #(hbus_transaction) hbus_in;
  uvm_analysis_export #(yapp_packet)      chan0_in;
  uvm_analysis_export #(yapp_packet)      chan1_in;
  uvm_analysis_export #(yapp_packet)      chan2_in;

  //----------------------------------------------------------------------------
  // Constructor
  //----------------------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //----------------------------------------------------------------------------
  // Build Phase: Instantiate the components and exports using the factory
  //----------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Build internal components
    scoreboard = router_scoreboard::type_id::create("scoreboard", this);
    reference  = router_reference::type_id::create("reference", this);

    // NEW: Build the top-level exports
    yapp_in  = new("yapp_in", this);
    hbus_in  = new("hbus_in", this);
    chan0_in = new("chan0_in", this);
    chan1_in = new("chan1_in", this);
    chan2_in = new("chan2_in", this);
  endfunction : build_phase

  //----------------------------------------------------------------------------
  // Connect Phase: Wire surface exports to internal imps
  //----------------------------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect the valid YAPP analysis port of the reference model 
    // to the YAPP analysis imp of the scoreboard model (from 9B)
    reference.reference_out.connect(scoreboard.yapp_in);

    // NEW: Connect surface exports to internal component imps
    yapp_in.connect(reference.yapp_in);
    hbus_in.connect(reference.hbus_in);
    
    chan0_in.connect(scoreboard.chan0_out);
    chan1_in.connect(scoreboard.chan1_out);
    chan2_in.connect(scoreboard.chan2_out);
  endfunction : connect_phase

endclass : router_module_env
