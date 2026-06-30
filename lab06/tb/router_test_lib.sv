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
    uvm_config_wrapper::set(this, "tb.env.agent.sequencer.run_phase", "default_sequence",  yapp_base_seq::type_id::get());

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
    phase.phase_done.set_drain_time(this, 200ns);
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

// ------------------------------------------------------------------------------
// 3. DERIVED short_packet_test CLASS
// ------------------------------------------------------------------------------
class short_packet_test extends base_test;

  // Register short_packet_test with the factory
  `uvm_component_utils(short_packet_test)

  // Explicit constructor required for instance naming
  function new(string name = "short_packet_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // Build phase to handle infrastructure setup and apply factory overrides
  function void build_phase(uvm_phase phase);
    
    // 1. Execute base_test build_phase first to allocate the router_tb and default sequences
    super.build_phase(phase);

    // 2. Apply the factory type override
    yapp_packet::type_id::set_type_override(short_yapp_packet::type_id::get());
    
  endfunction : build_phase

endclass : short_packet_test

// ------------------------------------------------------------------------------
// 4. DERIVED set_config_test CLASS
// ------------------------------------------------------------------------------
class set_config_test extends base_test;

  // Register set_config_test with the factory
  `uvm_component_utils(set_config_test)

  // Explicit constructor required for instance naming
  function new(string name = "set_config_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // Build phase to handle infrastructure setup and apply factory overrides
  function void build_phase(uvm_phase phase);
    
    // 1. Execute base_test build_phase first to allocate the components
    super.build_phase(phase);

    // 2. b. Update configuration pathname to reflect the router_tb "tb" encapsulation layer
    set_config_int("tb.env.agent", "is_active", UVM_PASSIVE);
    
  endfunction : build_phase

endclass : set_config_test

// ------------------------------------------------------------------------------
// 5. DERIVED short_incr_payload CLASS
// ------------------------------------------------------------------------------
class short_incr_payload extends base_test;

  // Register short_incr_payload with the UVM factory
  `uvm_component_utils(short_incr_payload)

  // Standard component constructor
  function new(string name = "short_incr_payload", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // Build phase to handle infrastructure setup and apply factory overrides
  function void build_phase(uvm_phase phase);
    
    // 1. Execute base_test build_phase first to allocate env components
    super.build_phase(phase);

    // 2. b. Update configuration pathname hierarchy to match the new container depth
    uvm_config_wrapper::set(this, 
                            "tb.env.agent.sequencer.run_phase", 
                            "default_sequence",  
                            yapp_incr_payload_seq::type_id::get());
        
    // 3. Factory Type Override: Substitute base yapp_packet with short_yapp_packet
    set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
        
  endfunction : build_phase

endclass : short_incr_payload

// ------------------------------------------------------------------------------
// 6. YAPP Exhaustive Sequence Test Class
// ------------------------------------------------------------------------------
class exhaustive_seq_test extends base_test;

  // Register the test class with the UVM factory
  `uvm_component_utils(exhaustive_seq_test)

  // Declare a handle for the custom sequence library
  yapp_seq_lib seq_lib;

  // Explicit constructor creating the sequence library instance
  function new(string name = "exhaustive_seq_test", uvm_component parent = null);
    super.new(name, parent);
    seq_lib = yapp_seq_lib::type_id::create("seq_lib");
  endfunction : new

  // Build phase to handle component setup, library tuning, and configuration
  function void build_phase(uvm_phase phase);
    
    // Execute base_test build_phase first to build env infrastructure
    super.build_phase(phase);

    // Force cyclic randomization (all sequences run once before any repeat)
    seq_lib.selection_mode = UVM_SEQ_LIB_RANDC;
        
    // Set execution count bounds exactly to the number of registered sequences (6)
    seq_lib.min_random_count = 6;
    seq_lib.max_random_count = 6;

    // b. Update configuration database pathname path to account for the "tb" layer
    uvm_config_db#(uvm_sequence_base)::set(this, 
                                           "tb.env.agent.sequencer.run_phase", 
                                           "default_sequence",  
                                           seq_lib);
        
    // Factory Type Override: Substitute standard packets with short packets
    set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
        
  endfunction : build_phase

  // End of elaboration phase for debug display and structure verification
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    
    // Print the internal state, tables, and sequence list inside the library instance
    `uvm_info("SEQ_LIB_DEBUG", "Displaying configured sequence library properties:", UVM_LOW)
    seq_lib.print();
  endfunction : end_of_elaboration_phase

endclass : exhaustive_seq_test
