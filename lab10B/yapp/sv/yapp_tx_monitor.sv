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

  // --- REQ4 Tracking Variables ---
  yapp_packet prev_packet;           // Remembers historical packet fields for transitions
  bit         back_to_back;          // Asserted high if zero idle delay cycles occur
  bit         is_first_pkt = 1;      // Guard flag to initialize tracking
  int         clk_cnt = 0;           // Universal clock cycle tracking engine
  int         last_pkt_end_cycle = -999;
  int         curr_pkt_start_cycle = 0;

  //----------------------------------------------------------------------------
  // Covergroup Definition for Functional Coverage
  //----------------------------------------------------------------------------
  covergroup yapp_packet_cg;
    option.per_instance = 1;

    // REQ1: Ensure all lengths of packets are sent into dut with specific buckets
    length_cp: coverpoint packet_collected.length {
      bins MIN     = {1};
      bins MAX     = {63};
      bins BABY    = {[2:10]};
      bins TEENY   = {[11:40]};
      bins GROWNUP = {[41:62]};
    }

    // REQ2: Step 6 Address coverpoint using array bins for distinct calculation tracking
    addr_cp: coverpoint packet_collected.addr {
      bins valid_addrs[] = {[0:2]};  // Array bins catch if address 2 was ungenerated
      bins illegal_addr  = {3};      // Tracking count of packets sent to address 3
    }

    // REQ3 Workaround: Filter address 3 at the coverpoint level via iff expression
    addr_req3_cp: coverpoint packet_collected.addr iff (packet_collected.addr != 3) {
      bins valid_addrs[] = {[0:2]};
    }

    // REQ3 Workaround: Filter GOOD_PARITY out at the coverpoint level via iff expression
    parity_req3_cp: coverpoint packet_collected.parity_type iff (packet_collected.parity_type == BAD_PARITY) {
      bins bad_parity = {BAD_PARITY};
    }

    // REQ3: Cross tracking without using forbidden ignore_bins inside the cross block
    size_x_addr_x_parity: cross length_cp, addr_req3_cp, parity_req3_cp;

    // REQ4 (Optional): Transitions on Current Address
    //curr_addr_cp: coverpoint packet_collected.addr {
     // bins addrs[] = {[0:3]};
    //}

    // REQ4 (Optional): Transitions on Previous Address (Guarded against first packet null spaces)
    //prev_addr_cp: coverpoint prev_packet.addr iff (prev_packet != null) {
    //  0bins addrs[] = {[0:3]};
    //}

    // REQ4 (Optional): Guarded cross modeling consecutive address transitions
    //address_transition_cross: cross prev_addr_cp, curr_addr_cp iff (back_to_back == 1);

  endgroup : yapp_packet_cg

  //----------------------------------------------------------------------------
  // Constructor: new
  //----------------------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
    num_pkt_col = 0;
    item_collected_port = new("item_collected_port", this);
    yapp_packet_cg = new();
  endfunction : new

  //----------------------------------------------------------------------------
  // Build Phase
  //----------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase); 
    if (!yapp_vif_config::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", {"vif not set for: ", get_full_name(), ".vif"})
    end
  endfunction : build_phase

  //----------------------------------------------------------------------------
  // Run Phase
  //----------------------------------------------------------------------------
  virtual task run_phase(uvm_phase phase);
    `uvm_info("MON_RUN", "Inside the run_phase of yapp_tx_monitor", UVM_LOW)
    
    @(negedge vif.reset);
    `uvm_info(get_type_name(), "Detected Reset Done", UVM_MEDIUM)

    fork
      // Background Engine: Monitors absolute interface time ticks
      forever begin
        @(posedge vif.clock);
        clk_cnt++;
      end
      // Main Execution Loop: Tracks packet streams sequentially
      forever begin
        collect_packet();
      end
    join
  endtask : run_phase

  extern virtual task collect_packet();

  //----------------------------------------------------------------------------
  // Report Phase
  //----------------------------------------------------------------------------
  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: YAPP Monitor Collected %0d Packets", num_pkt_col), UVM_LOW)
  endfunction : report_phase

endclass : yapp_tx_monitor


//----------------------------------------------------------------------------
// Task: collect_packet
//----------------------------------------------------------------------------
task yapp_tx_monitor::collect_packet();
  // Synchronous detection to cleanly capture consecutive back-to-back assertions
  @(posedge vif.clock iff (vif.data_vld && !vif.in_suspend));

  // Determine back-to-back state relationship with the preceding cycle space
  curr_pkt_start_cycle = clk_cnt;
//  if (!is_first_pkt && (curr_pkt_start_cycle == last_pkt_end_cycle + 1)) begin
  //  back_to_back = 1;
  //end else begin
   // back_to_back = 0;
 // end

  // Instantiation of a fresh packet object container
  packet_collected = yapp_packet::type_id::create("packet_collected");
  void'(this.begin_tr(packet_collected, {get_name(), "_Packet"}));
  `uvm_info(get_type_name(), "Collecting a packet", UVM_HIGH)
  
  // Collect Header {Length, Addr} using vif.in_data
  { packet_collected.length, packet_collected.addr }  = vif.in_data;
  packet_collected.payload = new[packet_collected.length];
  
  // Collect the Payload
  for (int i=0; i< packet_collected.length; i++) begin
     @(posedge vif.clock iff (!vif.in_suspend));
     packet_collected.payload[i] = vif.in_data;
  end

  // Collect Parity on the next valid clock edge
  @(posedge vif.clock iff (!vif.in_suspend));
  packet_collected.parity = vif.in_data;
  packet_collected.parity_type = (packet_collected.parity == packet_collected.calc_parity()) ? GOOD_PARITY : BAD_PARITY;

  // Record the transaction completion timestamp reference
 // last_pkt_end_cycle = clk_cnt;

  `uvm_info(get_type_name(), $sformatf("Parity Type: %s  Parity : %h  Computed Parity: %h", 
            packet_collected.parity_type.name(), packet_collected.parity, packet_collected.calc_parity()), UVM_FULL)
  
  this.end_tr(packet_collected);
  `uvm_info(get_type_name(), $sformatf("%s Packet collected :\n%s", get_name(), packet_collected.sprint()), UVM_LOW)
  
  // Sample functional coverage matrix
  yapp_packet_cg.sample();

  // Save history: Shallow copy current packet into the historical reference block
 // if (packet_collected != null) begin
   // $cast(prev_packet, packet_collected.clone());
   // is_first_pkt = 0;
  //end

  // Send packet to scoreboard via TLM write()
  item_collected_port.write(packet_collected);
  num_pkt_col++;
endtask : collect_packet
