/*-----------------------------------------------------------------
File name     : yapp_if.sv
Description   :
Notes         :
-------------------------------------------------------------------
-----------------------------------------------------------------*/

interface yapp_if (input clock, input reset );

  // Actual Signals
  logic              data_vld;
  logic              in_suspend;
  logic       [7:0]  in_data;
  
  // Control flags
 // bit                has_checks = 1;
  //bit                has_coverage = 1;

endinterface : yapp_if


