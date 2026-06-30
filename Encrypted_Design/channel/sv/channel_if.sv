/*-----------------------------------------------------------------
File name     : channel_if.sv
Description   :
Notes         :
-------------------------------------------------------------------
-----------------------------------------------------------------*/

interface channel_if (input clock, input reset );

  // Actual Signals
  logic              data_vld;
  logic              suspend;
  logic       [7:0]  data;
  
  // Control flags
  bit                has_checks = 1;
  bit                has_coverage = 1;

endinterface : channel_if

