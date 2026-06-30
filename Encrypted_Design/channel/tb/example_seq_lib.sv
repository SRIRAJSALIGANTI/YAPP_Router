/*-----------------------------------------------------------------
File name     : example_seqs.sv
Description   : This file implements project-specific sequences
Notes         : Each sequence implements a typical scenario or a
              : combination of existing scenarios.
              : Use this file to define sequences that are specific
              : only to this project (not reusable at a higher level)
              : Reusable sequences belong in the sv/channel_*_seqs.sv files.
-------------------------------------------------------------------
-----------------------------------------------------------------*/

`ifndef EXAMPLE_SEQS_SV
`define EXAMPLE_SEQS_SV

//------------------------------------------------------------------------------
//
// SEQUENCE: channel_incr_payload_seq
//
//------------------------------------------------------------------------------
 
class channel_incr_payload_seq extends uvm_sequence #(yapp_packet);

  // Sequence data item
  yapp_packet packet;

  // Required macro for sequences automation
  `uvm_object_utils(channel_incr_payload_seq)

  // Parameters for this sequence
  rand int unsigned cnt;
  rand bit [7:0] start_data;

  // Parameter Constraints
  constraint count_ct { cnt >0; cnt <= 5;}

  // Constructor
  function new(string name="channel_incr_payload_seq");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    begin
      `uvm_info(get_type_name(), $sformatf("Executing channel_incr_payload_seq %0d times", cnt), UVM_LOW);
      for (int i=0; i<cnt; i++) begin
        // Allocate
        `uvm_create(packet)
        // Randomize
        void'(packet.randomize() with { packet.payload[0] == start_data;
               foreach(payload[i]) i>0 -> payload[i] == payload[i-1] +1; });
/*
        void'(packet.randomize());
        // Set the payload values
        for (int i=0; i<packet.payload.size(); i++)
            packet.payload[i] = start_data++;
        packet.parity = packet.calc_parity();
*/
        // Send to Driver
        `uvm_send(packet)
       end
    end
  endtask
  
endclass : channel_incr_payload_seq

`endif // EXAMPLE_SEQS_SV

