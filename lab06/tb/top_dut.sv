////////////////////////////////////////////////////////////////////////////////
// File name     : top_dut.sv
// Description   : Top-level module containing the YAPP router DUT 
//                 and interface instantiation.
////////////////////////////////////////////////////////////////////////////////

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "../sv/yapp_if.sv"
`include "../sv/yapp.svh"

module top_dut;

  // Clock and Reset Signals
  bit clock;
  bit reset;

  // Instantiate the YAPP Interface
  yapp_if in0 (clock, reset);

 //----------------------------------------------------------------------------
  // Instantiate the DUT and Map to Interface Signals
  //----------------------------------------------------------------------------
  yapp_router dut (
    .clock      (clock),
    .reset      (reset),
    
    // Connect to YAPP Interface input signals
    .in_data    (in0.in_data),
    
    // FIXED: DUT port is 'in_data_vld', connected to interface signal 'data_vld'
    .in_data_vld(in0.data_vld), 
    
    // Connected directly to interface so DUT controls the backpressure suspend line
    .in_suspend (in0.in_suspend),
    
    // Tie the Channel Suspend inputs to 0 to allow packets to pass through
    .suspend_0  (1'b0),
    .suspend_1  (1'b0),
    .suspend_2  (1'b0),
    
    // Output channels (Left open for future scoreboard/egress monitor connections)
    .data_0     (),
    .data_vld_0 (),
    .data_1     (),
    .data_vld_1 (),
    .data_2     (),
    .data_vld_2 ()
  );
  // Stimulus Generation Block for Clock and Reset
  initial begin
    reset <= 1'b1;
    clock <= 1'b1;
    #50 reset = 1'b0;
  end
    
  // Clock Oscillator (100MHz / 10ns Period)
  always #5 clock = ~clock;

  // UVM Test Execution block
  initial begin
    // Set the virtual interface in the UVM configuration database
    yapp_vif_config::set(null, "*", "vif", in0);
    
    // Execute the target verification test
    run_test("short_incr_payload");
  end

endmodule : top_dut
