////////////////////////////////////////////////////////////////////////////////
// File name     : top_dut.sv
// Description   : Top-level module instantiating the YAPP router DUT,
//                 YAPP interface, HBUS interface, and 3 Channel interfaces.
////////////////////////////////////////////////////////////////////////////////
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "../yapp/sv/yapp.svh"
`include "../../Encrypted_Design/Encrypted/yapp_router.svh"
`include "../../Encrypted_Design/channel/sv/channel_if.sv"
`include "../../Encrypted_Design/channel/sv/channel.svh"
`include "../../Encrypted_Design/hbus/sv/hbus_if.sv"
`include "../../Encrypted_Design/hbus/sv/hbus_pkg.svp"
import hbus_pkg::*;
`include "router_virtual_sequencer.sv"
`include "router_virtual_seqs.sv"
`include "../yapp/sv/router.svh"
`include "router_tb.sv"
//`include "router_test_lib.sv"
`include "router_vtest_lib.sv"

module top_dut;

  // Clock and Reset Signals
  bit clock;
  bit reset;

  // a. Instantiate the Hardware Interfaces
  yapp_if    in0 (clock, reset);
  hbus_if    hbus_in (clock, reset);
  channel_if ch0 (clock, reset);
  channel_if ch1 (clock, reset);
  channel_if ch2 (clock, reset);

  //----------------------------------------------------------------------------
  // b. Instantiate the DUT and Map to All Interface Signals
  //----------------------------------------------------------------------------
  yapp_router dut (
    .clock      (clock),
    .reset      (reset),
    .error      (error),
    
    // Connect to YAPP Ingress Interface
    .in_data    (in0.in_data),
    .in_data_vld(in0.data_vld), 
    .in_suspend (in0.in_suspend),
    
    // Connect to HBUS Configuration Interface
    .hen        (hbus_in.hen),
    .hwr_rd     (hbus_in.hwr_rd),
    .haddr      (hbus_in.haddr),
    .hdata      (hbus_in.hdata_w),
    
    // Connect to Channel 0 Egress Interface
    .data_0     (ch0.data),
    .data_vld_0 (ch0.data_vld),
    .suspend_0  (ch0.suspend),
    
    // Connect to Channel 1 Egress Interface
    .data_1     (ch1.data),
    .data_vld_1 (ch1.data_vld),
    .suspend_1  (ch1.suspend),
    
    // Connect to Channel 2 Egress Interface
    .data_2     (ch2.data),
    .data_vld_2 (ch2.data_vld),
    .suspend_2  (ch2.suspend)
  );

  // Stimulus Generation Block for Clock and Reset
  initial begin
    #1;
    reset = 1'b1;
    clock = 1'b1;
    #50 reset = 1'b0;
  end
    
  // Clock Oscillator (100MHz / 10ns Period)
  always #5 clock = ~clock;

  // UVM Test Execution block
  initial begin
    // d. Set Virtual Interfaces in the UVM Configuration Database using Typedefs
    // Context is null, and path expressions use wildcards to target all sub-components
    yapp_vif_config::set(null, "*", "vif", in0);
    hbus_vif_config::set(null, "*.hbus*", "vif", hbus_in);
    
    channel_vif_config::set(null, "*.chan0*", "vif", ch0);
    channel_vif_config::set(null, "*.chan1*", "vif", ch1);
    channel_vif_config::set(null, "*.chan2*", "vif", ch2);
    
    // Execute the target verification test
    run_test("router_virtual_test");
  end

endmodule : top_dut
