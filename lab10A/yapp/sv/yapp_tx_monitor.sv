//------------------------------------------------------------------------------
// Component: yapp_tx_monitor
// Description: Passive component that samples the DUT signals to capture packets
//------------------------------------------------------------------------------

class yapp_tx_monitor extends uvm_monitor;

  // Register the monitor with the UVM Factory
  `uvm_component_utils(yapp_tx_monitor)

  // Virtual interface declaration
  virtual interface yapp_if vif; 

  // TLM Analysis Port to broadcast collected packets to scoreboard/coverage components
  uvm_analysis_port #(yapp_packet) item_collected_port;

  // Declarations for variables utilized by the collect_packet() routine
  yapp_packet packet_collected;
  int num_pkt_col;

  //----------------------------------------------------------------------------
  // Constructor: new
  //----------------------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
    num_pkt_col = 0;
       // Instantiate the TLM analysis port
    item_collected_port = new("item_collected_port", this);
  endfunction : new

  //----------------------------------------------------------------------------
  // Build Phase: Retrieve the interface connection and instantiate ports
  //----------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase); 
    // Get the virtual interface hook from the configuration database
    if (!yapp_vif_config::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", {"vif not set for: ", get_full_name(), ".vif"})
    end
  endfunction : build_phase

  //----------------------------------------------------------------------------
  // Task: run_phase
  // Automatically called by the phase controller to execute parallel monitoring
  //----------------------------------------------------------------------------
  virtual task run_phase(uvm_phase phase);
    `uvm_info("MON_RUN", "Inside the run_phase of yapp_tx_monitor", UVM_LOW)
    
    // Look for packets after reset drops
    @(negedge vif.reset);
    `uvm_info(get_type_name(), "Detected Reset Done", UVM_MEDIUM)

    // Process transactions sequentially for the lifetime of the simulation
    forever begin
      collect_packet();
    end
  endtask : run_phase

  // Prototype declaration for the external packet extraction task
  extern virtual task collect_packet();

    // UVM report_phase
  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: YAPP Monitor Collected %0d Packets", num_pkt_col), UVM_LOW)
  endfunction : report_phase

  
endclass : yapp_tx_monitor


//----------------------------------------------------------------------------
// Task: collect_packet
// Collect yapp_packets by sampling physical pins on clock edges
//----------------------------------------------------------------------------
task yapp_tx_monitor::collect_packet();
  // 1. MATCHED INTERFACE SIGNAL: Changed to vif.data_vld
  // Monitor looks at the bus on posedge when data is valid and not suspended
      @(posedge vif.data_vld);

      @(posedge vif.clock iff (!vif.in_suspend))

  // Instantiation of a fresh packet object container
  packet_collected = yapp_packet::type_id::create("packet_collected");

  // Begin transaction recording (for waves/GUI debuggers)
  void'(this.begin_tr(packet_collected, {get_name(), "_Packet"}));
  `uvm_info(get_type_name(), "Collecting a packet", UVM_HIGH)
  
  // 2. MATCHED INTERFACE SIGNAL: Collect Header {Length, Addr} using vif.in_data
  { packet_collected.length, packet_collected.addr }  = vif.in_data;
  packet_collected.payload = new[packet_collected.length]; // Allocate the payload
  
  // 3. MATCHED INTERFACE SIGNALS: Collect the Payload using vif.in_suspend and vif.in_data
  for (int i=0; i< packet_collected.length; i++) begin
     @(posedge vif.clock iff (!vif.in_suspend));
     packet_collected.payload[i] = vif.in_data;
  end

  // 4. MATCHED INTERFACE SIGNALS: Collect Parity on the next valid clock edge
  @(posedge vif.clock iff (!vif.in_suspend));
  packet_collected.parity = vif.in_data;
  packet_collected.parity_type = (packet_collected.parity == packet_collected.calc_parity()) ? GOOD_PARITY : BAD_PARITY;
  
  `uvm_info(get_type_name(), $sformatf("Parity Type: %s  Parity : %h  Computed Parity: %h", 
            packet_collected.parity_type.name(), packet_collected.parity, packet_collected.calc_parity()), UVM_FULL)
  
  // End transaction recording
  this.end_tr(packet_collected);
  `uvm_info(get_type_name(), $sformatf("%s Packet collected :\n%s", get_name(), packet_collected.sprint()), UVM_LOW)
  
  // Send packet to scoreboard via TLM write()
  item_collected_port.write(packet_collected);
  num_pkt_col++;
endtask : collect_packet
