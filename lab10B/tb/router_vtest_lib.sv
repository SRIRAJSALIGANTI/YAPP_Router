// ==============================================================================
// File Name: router_vtest_lib.sv
// Purpose: Test library for executing multi-protocol virtual sequences
// ==============================================================================

class base_test extends uvm_test;

  `uvm_component_utils(base_test)

  router_tb tb;

  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tb = router_tb::type_id::create("tb", this);
  endfunction : build_phase

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase

endclass : base_test


//------------------------------------------------------------------------------
// TEST: router_virtual_test
//------------------------------------------------------------------------------
class router_virtual_test extends base_test;

  `uvm_component_utils(router_virtual_test)

  function new(string name = "router_virtual_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase); 
    
    // Set a type override for short packets only
    set_type_override("yapp_packet", "short_yapp_packet");

    // Set the default sequence of all output channel sequencers to channel_rx_resp_seq
    uvm_config_wrapper::set(this, "tb.chan0.rx_agent.sequencer.run_phase", "default_sequence", channel_rx_resp_seq::type_id::get());
    uvm_config_wrapper::set(this, "tb.chan1.rx_agent.sequencer.run_phase", "default_sequence", channel_rx_resp_seq::type_id::get());
    uvm_config_wrapper::set(this, "tb.chan2.rx_agent.sequencer.run_phase", "default_sequence", channel_rx_resp_seq::type_id::get());

    // Set the default sequence of the virtual sequencer to the router_simple_vseq sequence
    uvm_config_wrapper::set(this, "tb.v_sqr.run_phase", "default_sequence", router_simple_vseq::type_id::get());
  endfunction : build_phase

endclass : router_virtual_test


//------------------------------------------------------------------------------
// TEST: router_dynamic_test (Lab 10 Parts 1 & 2)
// Description: Runs the dynamic on-the-fly packet testing profile.
//------------------------------------------------------------------------------
class router_dynamic_test extends base_test;

  `uvm_component_utils(router_dynamic_test)

  function new(string name = "router_dynamic_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase); 

    // Configure the channel UVC monitors to respond to read transactions
    uvm_config_wrapper::set(this, "tb.chan0.rx_agent.sequencer.run_phase", "default_sequence", channel_rx_resp_seq::type_id::get());
    uvm_config_wrapper::set(this, "tb.chan1.rx_agent.sequencer.run_phase", "default_sequence", channel_rx_resp_seq::type_id::get());
    uvm_config_wrapper::set(this, "tb.chan2.rx_agent.sequencer.run_phase", "default_sequence", channel_rx_resp_seq::type_id::get());

    // Hook up our new dynamic virtual sequence to execute during run_phase
    uvm_config_wrapper::set(this, "tb.v_sqr.run_phase", "default_sequence", router_dynamic_vseq::type_id::get());
  endfunction : build_phase

endclass : router_dynamic_test

//------------------------------------------------------------------------------
// TEST: router_disable_enable_test (Lab 10 Parts 3 & 4)
//------------------------------------------------------------------------------
class router_disable_enable_test extends base_test;

  `uvm_component_utils(router_disable_enable_test)

  function new(string name = "router_disable_enable_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase); 

    // Enable passive port auto-responses so transactions clear the channel drivers
    uvm_config_wrapper::set(this, "tb.chan0.rx_agent.sequencer.run_phase", "default_sequence", channel_rx_resp_seq::type_id::get());
    uvm_config_wrapper::set(this, "tb.chan1.rx_agent.sequencer.run_phase", "default_sequence", channel_rx_resp_seq::type_id::get());
    uvm_config_wrapper::set(this, "tb.chan2.rx_agent.sequencer.run_phase", "default_sequence", channel_rx_resp_seq::type_id::get());

    // Connect our brand new sequence to run automatically during the run phase
    uvm_config_wrapper::set(this, "tb.v_sqr.run_phase", "default_sequence", router_disable_enable_vseq::type_id::get());
  endfunction : build_phase

endclass : router_disable_enable_test

//------------------------------------------------------------------------------
// TEST: router_size_dist_test (Lab 10 Parts 6 & 7)
//------------------------------------------------------------------------------
class router_size_dist_test extends base_test;

  `uvm_component_utils(router_size_dist_test)

  function new(string name = "router_size_dist_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase); 

    // Enable passive port auto-responses for clear channel driver execution
    uvm_config_wrapper::set(this, "tb.chan0.rx_agent.sequencer.run_phase", "default_sequence", channel_rx_resp_seq::type_id::get());
    uvm_config_wrapper::set(this, "tb.chan1.rx_agent.sequencer.run_phase", "default_sequence", channel_rx_resp_seq::type_id::get());
    uvm_config_wrapper::set(this, "tb.chan2.rx_agent.sequencer.run_phase", "default_sequence", channel_rx_resp_seq::type_id::get());

    // Connect our new distribution sequence to the virtual sequencer run phase
    uvm_config_wrapper::set(this, "tb.v_sqr.run_phase", "default_sequence", router_size_dist_vseq::type_id::get());
  endfunction : build_phase

endclass : router_size_dist_test

//------------------------------------------------------------------------------
// TEST: router_coverage_test (Targeting 100% Functional Coverage)
//------------------------------------------------------------------------------
class router_coverage_test extends base_test;
  `uvm_component_utils(router_coverage_test)

  function new(string name = "router_coverage_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Enable passive port auto-responses for clear channel driver execution
    uvm_config_wrapper::set(this, "tb.chan0.rx_agent.sequencer.run_phase", "default_sequence", channel_rx_resp_seq::type_id::get());
    uvm_config_wrapper::set(this, "tb.chan1.rx_agent.sequencer.run_phase", "default_sequence", channel_rx_resp_seq::type_id::get());
    uvm_config_wrapper::set(this, "tb.chan2.rx_agent.sequencer.run_phase", "default_sequence", channel_rx_resp_seq::type_id::get());

    // Connect the new functional coverage sequence to the virtual sequencer's run_phase
    uvm_config_wrapper::set(this, "tb.v_sqr.run_phase", "default_sequence", router_exhaustive_coverage_vseq::type_id::get());
  endfunction : build_phase

endclass : router_coverage_test
