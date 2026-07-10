//------------------------------------------------------------------------------
// Component: router_reference
// Description: Reference model mimicking the Router DUT routing and 
//              register configuration logic.
//------------------------------------------------------------------------------

// Guard macro declarations to prevent multiply defined typedefs across components
`ifndef UVM_ANALYSIS_IMP_YAPP_DEFINED
  `define UVM_ANALYSIS_IMP_YAPP_DEFINED
  `uvm_analysis_imp_decl(_yapp)
`endif

  `uvm_analysis_imp_decl(_hbus)

class router_reference extends uvm_component;

  // Register component with the UVM factory
  `uvm_component_utils(router_reference)

  // Declare the two analysis imp objects for input data
  uvm_analysis_imp_yapp #(yapp_packet, router_reference)       yapp_in;
  uvm_analysis_imp_hbus #(hbus_transaction, router_reference)  hbus_in;

  // Define one analysis port object for output data to the scoreboard
  uvm_analysis_port #(yapp_packet) reference_out;

  // Variables to mirror the Router DUT registers with accurate reset values
  bit       router_enable = 1'b1;   // Address 0x01: Reset value of 1
  bit [7:0] max_pkt_size  = 8'h3F;  // Address 0x00: Reset value of 'h3F (63)

  // Separate counters for dropped packets metrics
  int num_dropped_enable = 0;
  int num_dropped_size   = 0;
  int num_dropped_addr   = 0;
  int num_forwarded      = 0;

  //----------------------------------------------------------------------------
  // Constructor
  //----------------------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //----------------------------------------------------------------------------
  // Build Phase: Instantiate Ports and Imps
  //----------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    yapp_in       = new("yapp_in", this);
    hbus_in       = new("hbus_in", this);
    reference_out = new("reference_out", this);
  endfunction : build_phase

  //----------------------------------------------------------------------------
  // HBUS Write Implementation: Aligned with hbus_if variable names
  //----------------------------------------------------------------------------
  virtual function void write_hbus(hbus_transaction transfer);
    // hwr_rd == 1 means a write operation based on interface assertions
    if (transfer.hwr_rd == 1'b1) begin
      case (transfer.haddr) // 8-bit address variable
        8'h00 : begin // Address 0 is MAXPKTSIZE
          max_pkt_size = transfer.hdata; // 8-bit data variable
          `uvm_info("REF_REG_UPDATE", $sformatf("MAXPKTSIZE register updated: %0d", max_pkt_size), UVM_MEDIUM)
        end
        8'h01 : begin // Address 1 is ROUTER_ENABLE
          router_enable = transfer.hdata[0]; 
          `uvm_info("REF_REG_UPDATE", $sformatf("ENABLE register updated: %0b", router_enable), UVM_MEDIUM)
        end
        default : begin
          `uvm_info("REF_HBUS_IGN", $sformatf("HBUS write to unmonitored address: 0x%0h", transfer.haddr), UVM_HIGH)
        end
      endcase
    end
  endfunction : write_hbus

  //----------------------------------------------------------------------------
  // YAPP Write Implementation: Validate and filter packets based on conditions
  //----------------------------------------------------------------------------
  virtual function void write_yapp(yapp_packet packet);
    yapp_packet pkt_clone;

    `uvm_info("REF_YAPP_RECV", $sformatf("Reference model received packet:\n%s", packet.sprint()), UVM_HIGH)

    // Check 1: Enable Violation
    if (!router_enable) begin
      num_dropped_enable++;
      `uvm_info("REF_PKT_DROP", "YAPP Packet dropped: Router is DISABLED.", UVM_HIGH)
      return;
    end

    // Check 2: Address Violation (DUT only routes to Channels 0, 1, and 2)
    if (packet.addr > 2) begin
      num_dropped_addr++;
      `uvm_info("REF_PKT_DROP", $sformatf("YAPP Packet dropped: Invalid Address (%0d).", packet.addr), UVM_HIGH)
      return;
    end

    // Check 3: Size / Length Violations (1 to max_pkt_size)
    if (packet.length == 0 || packet.length > max_pkt_size) begin
      num_dropped_size++;
      `uvm_info("REF_PKT_DROP", $sformatf("YAPP Packet dropped: Length (%0d) is out of bounds (1 to %0d).", packet.length, max_pkt_size), UVM_HIGH)
      return;
    end

    // If all conditions pass, clone and forward to the scoreboard
    num_forwarded++;
    $cast(pkt_clone, packet.clone());
    reference_out.write(pkt_clone);
    `uvm_info("REF_PKT_FWD", $sformatf("YAPP Packet validated and forwarded to Scoreboard. (Total Fwd: %0d)", num_forwarded), UVM_MEDIUM)
  endfunction : write_yapp

  //----------------------------------------------------------------------------
  // Report Phase: Summary of tracking statistics
  //----------------------------------------------------------------------------
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("REF_REPORT", $sformatf({
      "\n========================================================",
      "\n                ROUTER REFERENCE REPORT                 ",
      "\n========================================================",
      "\n Total Valid Packets Forwarded : %0d",
      "\n Packets Dropped (Disabled)     : %0d",
      "\n Packets Dropped (Invalid Addr) : %0d",
      "\n Packets Dropped (Size/Length)  : %0d",
      "\n========================================================"
    }, num_forwarded, num_dropped_enable, num_dropped_addr, num_dropped_size), UVM_LOW)
  endfunction : report_phase

endclass : router_reference
