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
    uvm_config_wrapper::set(this, "env.agent.sequencer.run_phase", "default_sequence",  yapp_base_seq::type_id::get());

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

// ------------------------------------------------------------------------------
// 3. DERIVED short_packet_test CLASS
// ------------------------------------------------------------------------------
class short_packet_test extends base_test;

  // Register test2 with the factory so you can call it using +UVM_TESTNAME=test2
  `uvm_component_utils(short_packet_test)

  // Explicit constructor required for test2 instance naming
  function new(string name = "short_packet_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // Build phase to handle infrastructure setup and apply factory overrides
  function void build_phase(uvm_phase phase);
    
    // 1. Execute base_test build_phase first to allocate env and set default sequences
    super.build_phase(phase);

    // 2. Apply the factory type override

    yapp_packet::type_id::set_type_override(short_yapp_packet::type_id::get());

    // Method B: String-based convenience method
    // set_type_override("yapp_packet", "short_yapp_packet");
    
  endfunction : build_phase

endclass : short_packet_test

// ------------------------------------------------------------------------------
// 4. DERIVED set_config_test CLASS
// ------------------------------------------------------------------------------
class set_config_test extends base_test;

  // Register set_config_test with the factory
  `uvm_component_utils(set_config_test)

  // Explicit constructor required for test2 instance naming
  function new(string name = "set_config_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // Build phase to handle infrastructure setup and apply factory overrides
  function void build_phase(uvm_phase phase);
    
    // 1. Execute base_test build_phase first to allocate env and set default sequences
    super.build_phase(phase);

    // 2. Apply the factory type override

    set_config_int("env.agent", "is_active", UVM_PASSIVE);

    // Method B: String-based convenience method
    // set_type_override("yapp_packet", "short_yapp_packet");
    
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

    // 2. Set the run_phase default sequence to target yapp_incr_payload_seq
    uvm_config_wrapper::set(this, 
                            "env.agent.sequencer.run_phase", 
                            "default_sequence",  
                            yapp_incr_payload_seq::type_id::get());
        
    // 3. Factory Type Override: Substitute base yapp_packet with short_yapp_packet
    // Whenever `uvm_create/`uvm_do requests a yapp_packet, the factory returns a short_yapp_packet instead.
    set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
        
  endfunction : build_phase

endclass : short_incr_payload

// ------------------------------------------------------------------------------
// 6. YAPP Exhaustive Sequence Test Class
// ------------------------------------------------------------------------------
class exhaustive_seq_test extends base_test;

  // Register the test class with the UVM factory
  `uvm_component_utils(exhaustive_seq_test)

  // b. Declare a handle for the custom sequence library
  yapp_seq_lib seq_lib;

  // b. Explicit constructor creating the sequence library instance
  function new(string name = "exhaustive_seq_test", uvm_component parent = null);
    super.new(name, parent);
    
    // Instantiating the sequence library here as strictly required by instructions
    seq_lib = yapp_seq_lib::type_id::create("seq_lib");
  endfunction : new

  // Build phase to handle component setup, library tuning, and configuration
  function void build_phase(uvm_phase phase);
    
    // Execute base_test build_phase first to build env infrastructure
    super.build_phase(phase);

    // c. Force cyclic randomization (all sequences run once before any repeat)
    seq_lib.selection_mode = UVM_SEQ_LIB_RANDC;
        
    // d. Set execution count bounds exactly to the number of registered sequences (6)
    // This guarantees every sequence runs exactly once in a randomized order.
    seq_lib.min_random_count = 6;
    seq_lib.max_random_count = 6;

    // e. Assign the pre-configured library instance as the default run_phase sequence
    // Note: We pass the instance handle 'seq_lib' directly instead of a type wrapper
    uvm_config_db#(uvm_sequence_base)::set(this, 
                                           "env.agent.sequencer.run_phase", 
                                           "default_sequence",  
                                           seq_lib);
        
    // f. Factory Type Override: Substitute standard packets with short packets
    set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
        
  endfunction : build_phase

  // g. End of elaboration phase for debug display and structure verification
  function void end_of_elaboration_phase(uvm_phase phase);
    // Execute super phase to retain any top-level print_topology() calls from base_test
    super.end_of_elaboration_phase(phase);
    
    // Print the internal state, tables, and sequence list inside the library instance
    `uvm_info("SEQ_LIB_DEBUG", "Displaying configured sequence library properties:", UVM_LOW)
    seq_lib.print();
  endfunction : end_of_elaboration_phase

endclass : exhaustive_seq_test
