//------------------------------------------------------------------------------
// Component: router_scoreboard
// Description: Scoreboard to verify YAPP router packet routing and integrity
//------------------------------------------------------------------------------
`ifndef UVM_ANALYSIS_IMP_YAPP_DEFINED
  `define UVM_ANALYSIS_IMP_YAPP_DEFINED
  `uvm_analysis_imp_decl(_yapp)
`endif
`uvm_analysis_imp_decl(_chan0) 
`uvm_analysis_imp_decl(_chan1) 
`uvm_analysis_imp_decl(_chan2) 

class router_scoreboard extends uvm_scoreboard; 

  // Register component with the UVM factory
  `uvm_component_utils(router_scoreboard) 

  // Declare all four analysis imp objects parameterized to yapp_packet
  uvm_analysis_imp_yapp  #(yapp_packet, router_scoreboard) yapp_in; 
  uvm_analysis_imp_chan0 #(yapp_packet, router_scoreboard) chan0_out; 
  uvm_analysis_imp_chan1 #(yapp_packet, router_scoreboard) chan1_out; 
  uvm_analysis_imp_chan2 #(yapp_packet, router_scoreboard) chan2_out; 

  // Internal storage queues for each valid destination address (0, 1, 2)
  yapp_packet router_q[3][$]; 

  // Counters for verification statistics (Dropped removed!)
  int num_received; 
  int num_match; 
  int num_wrong; 

  //----------------------------------------------------------------------------
  // Constructor: Instantiate analysis imp instances
  //----------------------------------------------------------------------------
  function new(string name, uvm_component parent); 
    super.new(name, parent); 
    
    yapp_in   = new("yapp_in",   this); 
    chan0_out = new("chan0_out", this); 
    chan1_out = new("chan1_out", this); 
    chan2_out = new("chan2_out", this); 

    num_received = 0; 
    num_match    = 0; 
    num_wrong    = 0; 
  endfunction : new 

  //----------------------------------------------------------------------------
  // YAPP Input Implementation: Trust pre-filtered packets from reference model
  //----------------------------------------------------------------------------
  virtual function void write_yapp(yapp_packet packet); 
    yapp_packet pkt_clone; 
    
    `uvm_info("SB_YAPP_RECV", $sformatf("Received expected packet from Reference Model:\n%s", packet.sprint()), UVM_HIGH) 
    
    num_received++; 

    $cast(pkt_clone, packet.clone()); 
    router_q[pkt_clone.addr].push_back(pkt_clone); 
    
    `uvm_info("SB_YAPP_RECV", $sformatf("Queued reference packet to Channel %0d Queue. Current Size: %0d", pkt_clone.addr, router_q[pkt_clone.addr].size()), UVM_HIGH)
  endfunction : write_yapp

  //----------------------------------------------------------------------------
  // Channel Output Implementations: Comparison logic using .compare()
  //----------------------------------------------------------------------------
  virtual function void write_chan0(yapp_packet packet); 
    yapp_packet exp_pkt; 

    `uvm_info("SB_CHAN_RECV", $sformatf("Received output packet from Channel 0 Monitor:\n%s", packet.sprint()), UVM_HIGH) 

    if (router_q[0].size() == 0) begin 
      `uvm_error("SB_MISMATCH", "Underflow Error! Channel 0 received a packet, but expected reference queue is empty.") 
      num_wrong++; 
      return; 
    end 

    exp_pkt = router_q[0].pop_front(); 

    if (packet.compare(exp_pkt)) begin 
      num_match++; 
      `uvm_info("SB_PASS", "SUCCESS: Packet comparison PASSED on Channel 0.", UVM_LOW) 
    end else begin 
      num_wrong++; 
      `uvm_error("SB_FAIL", $sformatf("MISMATCH ERROR: Packet comparison FAILED on Channel 0!\nExpected:\n%s\nObserved:\n%s", exp_pkt.sprint(), packet.sprint())) 
    end 
  endfunction : write_chan0 

  virtual function void write_chan1(yapp_packet packet); 
    yapp_packet exp_pkt; 

    `uvm_info("SB_CHAN_RECV", $sformatf("Received output packet from Channel 1 Monitor:\n%s", packet.sprint()), UVM_HIGH) 

    if (router_q[1].size() == 0) begin 
      `uvm_error("SB_MISMATCH", "Underflow Error! Channel 1 received a packet, but expected reference queue is empty.") 
      num_wrong++; 
      return; 
    end 

    exp_pkt = router_q[1].pop_front(); 

    if (packet.compare(exp_pkt)) begin 
      num_match++; 
      `uvm_info("SB_PASS", "SUCCESS: Packet comparison PASSED on Channel 1.", UVM_LOW) 
    end else begin 
      num_wrong++; 
      `uvm_error("SB_FAIL", $sformatf("MISMATCH ERROR: Packet comparison FAILED on Channel 1!\nExpected:\n%s\nObserved:\n%s", exp_pkt.sprint(), packet.sprint())) 
    end 
  endfunction : write_chan1 

  virtual function void write_chan2(yapp_packet packet); 
    yapp_packet exp_pkt; 

    `uvm_info("SB_CHAN_RECV", $sformatf("Received output packet from Channel 2 Monitor:\n%s", packet.sprint()), UVM_HIGH) 

    if (router_q[2].size() == 0) begin 
      `uvm_error("SB_MISMATCH", "Underflow Error! Channel 2 received a packet, but expected reference queue is empty.") 
      num_wrong++; 
      return; 
    end 

    exp_pkt = router_q[2].pop_front(); 

    if (packet.compare(exp_pkt)) begin 
      num_match++; 
      `uvm_info("SB_PASS", "SUCCESS: Packet comparison PASSED on Channel 2.", UVM_LOW) 
    end else begin 
      num_wrong++; 
      `uvm_error("SB_FAIL", $sformatf("MISMATCH ERROR: Packet comparison FAILED on Channel 2!\nExpected:\n%s\nObserved:\n%s", exp_pkt.sprint(), packet.sprint())) 
    end 
  endfunction : write_chan2 

  //----------------------------------------------------------------------------
  // Report Phase: Print structural summary metrics
  //----------------------------------------------------------------------------
  virtual function void report_phase(uvm_phase phase); 
    super.report_phase(phase); 
    
    `uvm_info("SB_REPORT", $sformatf({ 
      "\n========================================================", 
      "\n                  ROUTER SCOREBOARD REPORT               ", 
      "\n========================================================", 
      "\n Total Packets Expected (From Ref Model) : %0d", 
      "\n Total Packets Matched (PASSED)          : %0d", 
      "\n Total Packets Wrong   (FAILED)          : %0d", 
      "\n--------------------------------------------------------", 
      "\n Outstanding Packets Remaining In Queues:", 
      "\n   - Channel 0 Queue Size                : %0d", 
      "\n   - Channel 1 Queue Size                : %0d", 
      "\n   - Channel 2 Queue Size                : %0d", 
      "\n========================================================" 
    }, num_received, num_match, num_wrong, router_q[0].size(), router_q[1].size(), router_q[2].size()), UVM_LOW) 
    
    if ((router_q[0].size() + router_q[1].size() + router_q[2].size()) > 0) begin 
      `uvm_warning("SB_LEAK", "Simulation ended with untransmitted packets remaining inside the scoreboard queues!") 
    end 
  endfunction : report_phase 

endclass : router_scoreboard

