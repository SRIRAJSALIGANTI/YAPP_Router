//------------------------------------------------------------------------------
// Module: top
// Description: Top-level hardware testbench module. Instantiates the 
//              UVM environment topology and kicks off simulation phases.
//------------------------------------------------------------------------------

module top;

  // Import the UVM standard library package
  import uvm_pkg::*;

  // Include the standard UVM messaging and component macros
  `include "uvm_macros.svh"

  // Include the YAPP UVC aggregate header file (created in Step 7)

  `include "../sv/yapp.svh"

  base_test test;
  //----------------------------------------------------------------------------
  // Initial Block 1: Topology Construction
  // Allocates and registers the environment component with the UVM factory.
  //----------------------------------------------------------------------------
  initial begin
    // Correct UVM Factory Syntax. Parent is 'null' because 'top' is a module.
    test = base_test::type_id::create("test", null);
  end

  //----------------------------------------------------------------------------
  // Initial Block 2: Phase Execution Controller
  // Activates the UVM test runner to step through build, connect, and run phases.
  //----------------------------------------------------------------------------
  initial begin
    // Kicks off the simulation phases for any pre-constructed components
    run_test();

  end

endmodule : top
