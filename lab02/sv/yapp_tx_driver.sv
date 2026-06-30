//------------------------------------------------------------------------------
// Component: yapp_tx_driver
// Description: Transmitter driver for the YAPP UVC
//------------------------------------------------------------------------------

class yapp_tx_driver extends uvm_driver #(yapp_packet);
  
  // Register component with the UVM factory
  `uvm_component_utils(yapp_tx_driver)

  // Standard UVM Component Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // Run Phase: Automatically invoked by the UVM execution phase controller
  task run_phase(uvm_phase phase);
    yapp_packet pkt;
    
    forever begin
      // Pull the next available transaction sequence item from the sequencer
      seq_item_port.get_next_item(pkt);
      
      // Execute transaction protocol handshake on physical pins
      send_to_dut(pkt);
      
      // Acknowledge back to the sequencer that the transaction processed successfully
      seq_item_port.item_done();
    end
  endtask : run_phase

  // Send to DUT: Abstracted task to handle pin-level transitions
  task send_to_dut(yapp_packet pkt);
    // Note: Added '%s' placeholder so the string format matches your print output
    `uvm_info("DRV_SEND", $sformatf("Packet is \n%s", pkt.sprint()), UVM_LOW)
  endtask : send_to_dut

  // UVM Start of Simulation Phase
  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info("START_OF_SIM", $sformatf("Inside the start_of_simulation_phase of %s", get_type_name()), UVM_HIGH)
  endfunction : start_of_simulation_phase

endclass : yapp_tx_driver
