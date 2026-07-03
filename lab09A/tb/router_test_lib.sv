// ==============================================================================
// File Name: yapp_test_lib.sv
// Purpose: Top-level UVM software controller to configure and build the testbench
// ==============================================================================

// Define the base test class by extending the standard uvm_test base component
class base_test extends uvm_test;

  // Register base_test with the UVM factory to allow command-line test selection
  `uvm_component_utils(base_test)

  // a. Replace the yapp_env instance handle with a router_tb instance handle
  router_tb tb;

  // Standard component constructor assigning instance name and software parent link
  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // Top-down build phase to configure variables and allocate child components
  function void build_phase(uvm_phase phase);
    
    // b. Update hierarchical path reference to include the additional router_tb ("tb") handle
   // uvm_config_wrapper::set(this, "tb.env.agent.sequencer.run_phase", "default_sequence",  yapp_base_seq::type_id::get());

    // Call parent build phase to process baseline UVM-internal settings first
    super.build_phase(phase);

    // a. Instantiate the top-level router_tb container instead of the isolated yapp_env
    tb = router_tb::type_id::create("tb", this);
    
  endfunction : build_phase

  //----------------------------------------------------------------------------
  // c. Add a run_phase() method to inject a post-objection drain time delay
  //----------------------------------------------------------------------------
  virtual task run_phase(uvm_phase phase);
    // Introduce a tracking log message to verify execution
    `uvm_info(get_type_name(), "Inside the run_phase of base_test: setting objection drain time", UVM_LOW)
    phase.phase_done.set_drain_time(this, 500ns);
  endtask : run_phase

  // Milestone checkpoint phase executed after full testbench assembly completes
  function void end_of_elaboration_phase(uvm_phase phase);
    
    // Maintain baseline parent class execution routines for elaboration handling
    super.end_of_elaboration_phase(phase);
    
    // Print an informational tracking notification banner directly to the sim log
    `uvm_info("TOPOLOGY", "Printing the full structural testbench hierarchy layout:", UVM_LOW)
    
    // Command the UVM root manager to print the structured topology tree layout
    uvm_top.print_topology();
    
  endfunction : end_of_elaboration_phase

endclass : base_test


//------------------------------------------------------------------------------
// Class: simple_test
// Description: Extended from base_test to execute the yapp_012_seq sequence 
//              on the YAPP sequencer and channel_rx_resp_seq on all receiver 
//              channels while overriding packet types to short packets.
//------------------------------------------------------------------------------

class simple_test extends base_test;

  // Register simple_test with the UVM factory
  `uvm_component_utils(simple_test)

  //----------------------------------------------------------------------------
  // Constructor: new
  //----------------------------------------------------------------------------
  function new(string name = "simple_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //----------------------------------------------------------------------------
  // Function: build_phase
  //----------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    // Set the YAPP UVC to create short YAPP packets using factory type override
    set_type_override("yapp_packet", "short_yapp_packet");

    // Set the run_phase default sequence of the YAPP UVC to the yapp_012_seq sequence
    uvm_config_wrapper::set(this, "tb.env.agent.sequencer.run_phase", "default_sequence", yapp_012_seq::type_id::get());

    // Set the run_phase default sequence of each Channel UVC to channel_rx_resp_seq
    // (Can be done explicitly per instance or via a single wildcard string "tb.chan*.rx_agent.sequencer.run_phase")
    uvm_config_wrapper::set(this, "tb.chan0.rx_agent.sequencer.run_phase", "default_sequence", channel_rx_resp_seq::type_id::get());
    uvm_config_wrapper::set(this, "tb.chan1.rx_agent.sequencer.run_phase", "default_sequence", channel_rx_resp_seq::type_id::get());
    uvm_config_wrapper::set(this, "tb.chan2.rx_agent.sequencer.run_phase", "default_sequence", channel_rx_resp_seq::type_id::get());

    // Note: No default sequence configuration statement is added for the HBUS UVC

    // Call the parent build_phase to execute baseline settings and instantiate 'tb'
    super.build_phase(phase);
  endfunction : build_phase

endclass : simple_test
