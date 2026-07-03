//------------------------------------------------------------------------------
// Component: yapp_tx_driver
// Description: Transmitter driver for the YAPP UVC
//------------------------------------------------------------------------------

class yapp_tx_driver extends uvm_driver #(yapp_packet);
  
  // Register component with the UVM factory
  `uvm_component_utils(yapp_tx_driver)

  // c. Add a declaration for the virtual interface
  virtual interface yapp_if vif;

  // Declare this property to count packets sent
  int num_sent;

  // Standard UVM Component Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
    num_sent = 0;
  endfunction : new

  //----------------------------------------------------------------------------
  // d. Add a build_phase() method to retrieve the interface from config database
  //----------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if (!yapp_vif_config::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", {"vif not set for: ", get_full_name(), ".vif"})
    end
  endfunction : build_phase

  //----------------------------------------------------------------------------
  // Run Phase: Automatically invoked to execute driver processes in parallel
  //----------------------------------------------------------------------------
  virtual task run_phase(uvm_phase phase);
    fork
      get_and_drive();
      reset_signals();
    join
  endtask : run_phase

  // Prototype declarations for external class methods
  extern virtual task get_and_drive();
  extern virtual task reset_signals();
  extern virtual task send_to_dut(yapp_packet packet);

endclass : yapp_tx_driver


//----------------------------------------------------------------------------
// b. Update get_and_drive() to pull down packets from the sequencer
//----------------------------------------------------------------------------
task yapp_tx_driver::get_and_drive();
  @(negedge vif.reset);
  `uvm_info(get_type_name(), "Reset dropped", UVM_MEDIUM)
  forever begin
    yapp_packet pkt;
    // Get new item from the sequencer
    seq_item_port.get_next_item(pkt);
    // Drive the item
    send_to_dut(pkt);
    // Communicate item done to the sequencer
    seq_item_port.item_done();
  end
endtask : get_and_drive


//----------------------------------------------------------------------------
// Task: reset_signals
// Resets all input DUT signals when reset is active
//----------------------------------------------------------------------------
task yapp_tx_driver::reset_signals();
  forever begin
    @(posedge vif.reset);
    `uvm_info(get_type_name(), "Reset observed", UVM_MEDIUM)
    vif.in_data    <= 8'hz;
    vif.data_vld   <= 1'b0;
    disable send_to_dut;
  end
endtask : reset_signals


//----------------------------------------------------------------------------
// a. Task: send_to_dut
// Transmits sequential packet frames onto the physical pin interface
//----------------------------------------------------------------------------
task yapp_tx_driver::send_to_dut(yapp_packet packet);
  `uvm_info("DRV_SEND", $sformatf("Packet is \n%s", packet.sprint()), UVM_LOW)

  // Wait for packet delay
  repeat(packet.packet_delay)
    @(negedge vif.clock);

  // Start to send packet if not in_suspend signal
  @(negedge vif.clock iff (!vif.in_suspend));

  // Begin Transaction recording
  void'(this.begin_tr(packet, "Input_YAPP_Packet"));

  // Enable start packet signal
  vif.data_vld <= 1'b1;

  // Drive the Header {Length, Addr}
  vif.in_data <= { packet.length, packet.addr };

  // Drive Payload
  for (int i=0; i<packet.payload.size(); i++) begin
    @(negedge vif.clock iff (!vif.in_suspend));
    vif.in_data <= packet.payload[i];
  end

  // Drive Parity and reset Valid
  @(negedge vif.clock iff (!vif.in_suspend));
  vif.in_data <= packet.parity;

  // Return bus back to idle condition at the end of the frame
  @(negedge vif.clock);
  vif.data_vld <= 1'b0;
  vif.in_data  <= 8'h00;

  // End transaction recording
  this.end_tr(packet);
  num_sent++;
endtask : send_to_dut
