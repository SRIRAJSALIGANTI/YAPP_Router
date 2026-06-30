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

  // Declare the handle for the top-level YAPP environment container
  yapp_env env;

  //----------------------------------------------------------------------------
  // Initial Block 1: Topology Construction
  // Allocates and registers the environment component with the UVM factory.
  //----------------------------------------------------------------------------
  initial begin
    // Correct UVM Factory Syntax. Parent is 'null' because 'top' is a module.
    env = yapp_env::type_id::create("env", null);
  end

  //----------------------------------------------------------------------------
  // Initial Block 2: Phase Execution Controller
  // Activates the UVM test runner to step through build, connect, and run phases.
  //----------------------------------------------------------------------------
  initial begin
    // Kicks off the simulation phases for any pre-constructed components
    uvm_config_wrapper::set(null, "env.agent.sequencer.run_phase", 
	                    "default_sequence",
                            yapp_5_packets::type_id::get()); 
    run_test();

  end

endmodule : top
