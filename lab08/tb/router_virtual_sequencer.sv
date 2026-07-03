////////////////////////////////////////////////////////////////////////////////
// File name     : router_virtual_sequencer.sv
// Description   : Virtual sequencer containing handles to the sub-sequencers
//                 for coordinate sequence execution.
////////////////////////////////////////////////////////////////////////////////

class router_virtual_sequencer extends uvm_sequencer;

   // a. UVM Component Macro
  `uvm_component_utils(router_virtual_sequencer)

  // a. Constructor
  function new(string name = "router_virtual_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // b. Target sequencer references/handles
  yapp_tx_sequencer  yapp_seqr;
  hbus_master_sequencer     hbus_seqr;

endclass : router_virtual_sequencer
