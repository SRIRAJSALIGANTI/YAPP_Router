module top;
// import the UVM library
import uvm_pkg::*;

// include the UVM macros
`include "uvm_macros.svh"

// include the yapp_packet design
`include "../sv/yapp_packet.sv"
initial begin
    yapp_packet packet;

    for (int i = 0; i < 5; i++) begin
      // 1. Factory-create each unique packet instance
      packet = yapp_packet::type_id::create($sformatf("packet_%0d", i));

      // 2. Randomize fields (Triggers soft constraints & post_randomize parity calculation)
      if (!packet.randomize()) begin
        `uvm_fatal("RAND_FAIL", $sformatf("Failed to randomize packet_%0d", i))
      end
      $display("                  DISPLAYING PACKET [%0d]               ", i);
      // 3. Print Option A: Table Printer (The UVM Default standard)
      $display("\n UVM TABLE PRINTER:");
      packet.print(uvm_default_table_printer);

      // 4. Print Option B: Tree Printer (Hierarchical/JSON-like structure)
      $display("\n UVM TREE PRINTER:");
      packet.print(uvm_default_tree_printer);
    end
  end
endmodule
