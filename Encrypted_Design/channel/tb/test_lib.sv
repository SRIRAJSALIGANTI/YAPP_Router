/*-----------------------------------------------------------------
File name     : test_lib.sv
Description   : This file implements two kinds of test in the testbench.
Notes         : A test file verifies one or more cases in the test plan. 
-------------------------------------------------------------------
-----------------------------------------------------------------*/

`include "demo_tb.sv"

//----------------------------------------------------------------
//
// TEST: demo_base_test - Base test
//
//----------------------------------------------------------------
class demo_base_test extends uvm_test;

  `uvm_component_utils(demo_base_test)

  demo_tb tb;

  function new(string name = "demo_base_test", 
    uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Enable transaction recording for everything
    set_config_int("*", "recording_detail", UVM_FULL);
    // Create the testbench
    tb = demo_tb::type_id::create("tb", this);
  endfunction : build_phase

endclass : demo_base_test

//----------------------------------------------------------------
//
// TEST: default_sequence_test - sets the default sequences 
//
//----------------------------------------------------------------
class default_sequence_test extends demo_base_test;

  `uvm_component_utils(default_sequence_test)

  function new(string name = "default_sequence_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    // Set the default sequences for the tx and rx 
    uvm_config_wrapper::set(this, "tb.chan0.tx_agent.sequencer.main_phase",
                            "default_sequence",
                            channel_tx_nested_seq::type_id::get());

    uvm_config_wrapper::set(this, "tb.chan0.rx_agent.sequencer.main_phase",
                            "default_sequence",
                            channel_rx_resp_seq::type_id::get());
    // Create the testbench
    super.build_phase(phase);
  endfunction : build_phase

endclass : default_sequence_test

//----------------------------------------------------------------
//
// TEST: bad_parity_test - Executes the nested parity sequence
//
//----------------------------------------------------------------
class bad_parity_test extends demo_base_test;

  `uvm_component_utils(bad_parity_test)

  function new(string name = "bad_parity_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    // Set the default sequence for the tx and rx
    set_config_string("tb.chan0.tx_agent.sequencer","default_sequence","nested_parity_seq");
    set_config_string("tb.chan0.rx_agent.sequencer","default_sequence","channel_rx_resp_seq");
    // Create the testbench
    super.build_phase(phase);
  endfunction : build_phase

endclass : bad_parity_test
