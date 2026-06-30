// ==============================================================================
// File Name: base_test.sv
// Purpose: Top-level UVM software controller to configure and build the testbench
// ==============================================================================

// Define the base test class by extending the standard uvm_test base component
class base_test extends uvm_test;

  // Register base_test with the UVM factory to allow command-line test selection
  `uvm_component_utils(base_test)

  // Declare the pointer handle for the top-level verification environment container
  yapp_env env;

  // Standard component constructor assigning instance name and software parent link
  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // Top-down build phase to configure variables and allocate child components
  function void build_phase(uvm_phase phase);
    
    // Set the default traffic sequence on the sequencer using a relative context path
    uvm_config_wrapper::set(this, "env.agent.sequencer.run_phase", "default_sequence",  yapp_5_packets::type_id::get());

    // Call parent build phase to process baseline UVM-internal settings first
    super.build_phase(phase);

    // Instantiate the environment component in memory using the UVM factory allocation
    env = yapp_env::type_id::create("env", this);
    
  endfunction : build_phase

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

// ------------------------------------------------------------------------------
// 2. DERIVED TEST 2 CLASS
// ------------------------------------------------------------------------------
class test2 extends base_test;

  // Register test2 with the factory so you can call it using +UVM_TESTNAME=test2
  `uvm_component_utils(test2)

  // Explicit constructor required for test2 instance naming
  function new(string name = "test2", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

endclass : test2
