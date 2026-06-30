/*-----------------------------------------------
 IUS release without embedded UVM library,
 using library supplied with lab files.
------------------------------------------------*/
-uvmhome $UVMHOME

// include directories, starting with UVM src directory
-incdir ../sv

// uncomment for gui
//-gui
//+access+rwc

// default timescale
-timescale 1ns/100ps

// options
+UVM_VERBOSITY=UVM_LOW 
+UVM_TESTNAME=default_sequence_test

// compile files
// starting with UVM package and dpi files
$UVMHOME/src/dpi/uvm_dpi.cc
../sv/channel_if.sv 
//dut_dummy.v
demo_top.sv
