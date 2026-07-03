//------------------------------------------------------------------------------
// Component: router_scoreboard
// Description: Scoreboard to verify YAPP router packet routing and integrity
//------------------------------------------------------------------------------

`uvm_analysis_imp_decl(_yapp)
`uvm_analysis_imp_decl(_chan0)
`uvm_analysis_imp_decl(_chan1)
`uvm_analysis_imp_decl(_chan2)

class router_scoreboard extends uvm_scoreboard;

  // Register component with the UVM factory
  `uvm_component_utils(router_scoreboard)

  // a. Declare all four analysis imp objects parameterized to yapp_packet
  uvm_analysis_imp_yapp  #(yapp_packet, router_scoreboard) yapp_in;
  uvm_analysis_imp_chan0 #(yapp_packet, router_scoreboard) chan0_out;
  uvm_analysis_imp_chan1 #(yapp_packet, router_scoreboard) chan1_out;
  uvm_analysis_imp_chan2 #(yapp_packet, router_scoreboard) chan2_out;

  // c. Internal storage queues for each valid destination address (0, 1, 2)
  yapp_packet router_q[3][$];

  // e. Counters for verification statistics
  int num_received;
  int num_match;
  int num_wrong;

  //----------------------------------------------------------------------------
  // b. Constructor: Instantiate analysis imp instances
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
  // c. YAPP Input Implementation: Clone the packet and push to the specific queue
  //----------------------------------------------------------------------------
  virtual function void write_yapp(yapp_packet packet);
    yapp_packet pkt_clone;
    
    `uvm_info("SB_YAPP_RECV", $sformatf("Received input packet from YAPP Monitor:\n%s", packet.sprint()), UVM_HIGH)
    
    $cast(pkt_clone, packet.clone());
    num_received++;

    if (pkt_clone.addr >= 0 && pkt_clone.addr <= 2) begin
      router_q[pkt_clone.addr].push_back(pkt_clone);
    end else begin
      `uvm_error("SB_BAD_ADDR", $sformatf("Dropped packet with invalid router address: %0d", pkt_clone.addr))
      num_wrong++;
    end
  endfunction : write_yapp

  //----------------------------------------------------------------------------
  // d. Channel Output Implementations: Updated to accept yapp_packet
  //----------------------------------------------------------------------------
  virtual function void write_chan0(yapp_packet packet);
    check_packet(0, packet);
  endfunction : write_chan0

  virtual function void write_chan1(yapp_packet packet);
    check_packet(1, packet);
  endfunction : write_chan1

  virtual function void write_chan2(yapp_packet packet);
    check_packet(2, packet);
  endfunction : write_chan2

  //----------------------------------------------------------------------------
  // Helper Verification Method: Updated to compare two yapp_packet objects
  //----------------------------------------------------------------------------
  virtual function void check_packet(int chan_id, yapp_packet chan_pkt);
    yapp_packet exp_pkt;

    `uvm_info("SB_CHAN_RECV", $sformatf("Received output packet from Channel %0d Monitor:\n%s", chan_id, chan_pkt.sprint()), UVM_HIGH)

    // Check for Underflow
    if (router_q[chan_id].size() == 0) begin
      `uvm_error("SB_MISMATCH", $sformatf("Underflow Error! Channel %0d received a packet, but expected YAPP queue is empty.", chan_id))
      num_wrong++;
      return;
    end

    // Pop the golden reference packet
    exp_pkt = router_q[chan_id].pop_front();

    // Direct comparison using UVM's built-in compare() method
    if (chan_pkt.compare(exp_pkt)) begin
      num_match++;
      `uvm_info("SB_PASS", $sformatf("SUCCESS: Packet comparison PASSED on Channel %0d.", chan_id), UVM_LOW)
    end else begin
      num_wrong++;
      `uvm_error("SB_FAIL", $sformatf("MISMATCH ERROR: Packet comparison FAILED on Channel %0d!\nExpected:\n%s\nObserved:\n%s", 
                                      chan_id, exp_pkt.sprint(), chan_pkt.sprint()))
    end
  endfunction : check_packet

  //----------------------------------------------------------------------------
  // f. Report Phase: Print structural summary metrics
  //----------------------------------------------------------------------------
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    
    `uvm_info("SB_REPORT", $sformatf({
      "\n========================================================",
      "\n                 ROUTER SCOREBOARD REPORT               ",
      "\n========================================================",
      "\n Total Packets Received (YAPP Input) : %0d",
      "\n Total Packets Matched (PASSED)       : %0d",
      "\n Total Packets Wrong   (FAILED)       : %0d",
      "\n--------------------------------------------------------",
      "\n Outstanding Packets Remaining In Queues:",
      "\n   - Channel 0 Queue Size             : %0d",
      "\n   - Channel 1 Queue Size             : %0d",
      "\n   - Channel 2 Queue Size             : %0d",
      "\n========================================================"
    }, num_received, num_match, num_wrong, router_q[0].size(), router_q[1].size(), router_q[2].size()), UVM_LOW)
    
    if ((router_q[0].size() + router_q[1].size() + router_q[2].size()) > 0) begin
      `uvm_warning("SB_LEAK", "Simulation ended with untransmitted packets remaining inside the scoreboard queues!")
    end
  endfunction : report_phase

endclass : router_scoreboard
