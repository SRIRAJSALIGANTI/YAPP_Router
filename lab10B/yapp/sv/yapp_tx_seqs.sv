`ifndef YAPP_BASE_SEQ
`define YAPP_BASE_SEQ

// ------------------------------------------------------------------------------
// 1. Base Sequence Class with Automated Objection Management
// ------------------------------------------------------------------------------
class yapp_base_seq extends uvm_sequence #(yapp_packet);
  `uvm_object_utils(yapp_base_seq)

  function new(string name = "yapp_base_seq");
    super.new(name);
  endfunction

  virtual task pre_body();
    if (starting_phase != null) begin
      starting_phase.raise_objection(this);
      `uvm_info(get_type_name(), "Automated Objection RAISED", UVM_MEDIUM)
    end
  endtask : pre_body

  virtual task body();
    `uvm_info(get_type_name(), "exec-yapp_base_seq", UVM_LOW)
    repeat (5) begin
      yapp_packet pkt;
      pkt = yapp_packet::type_id::create("pkt");
      `uvm_do(pkt)
    end
  endtask : body

  virtual task post_body();
    if (starting_phase != null) begin
      starting_phase.drop_objection(this);
      `uvm_info(get_type_name(), "Automated Objection DROPPED", UVM_MEDIUM)
    end
  endtask : post_body

endclass
`endif

// ------------------------------------------------------------------------------
// 2. Incrementing Address Sequence (0 -> 1 -> 2)
// ------------------------------------------------------------------------------
class yapp_012_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_012_seq)

  function new(string name = "yapp_012_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info("SEQ_START", $sformatf("Executing sequence: %s", get_type_name()), UVM_LOW)
    `uvm_do_with(req, { addr == 0; })
    `uvm_do_with(req, { addr == 1; })
    `uvm_do_with(req, { addr == 2; })
  endtask : body

endclass : yapp_012_seq


// ------------------------------------------------------------------------------
// 3. Single Target Address 1 Sequence
// ------------------------------------------------------------------------------
class yapp_1_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_1_seq)

  function new(string name = "yapp_1_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info("SEQ_START", $sformatf("Executing sequence: %s", get_type_name()), UVM_LOW)
    `uvm_do_with(req, { addr == 1; })
  endtask : body

endclass : yapp_1_seq


// ------------------------------------------------------------------------------
// 4. Simple nested sequence Target Address 1
// ------------------------------------------------------------------------------
class yapp_111_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_111_seq)

  function new(string name = "yapp_111_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    yapp_1_seq single_seq;
    repeat (3) begin
      `uvm_do(single_seq)
    end  
  endtask : body

endclass : yapp_111_seq


// ------------------------------------------------------------------------------
// 5. Repeat Random Address Sequence
// ------------------------------------------------------------------------------
class yapp_repeat_addr_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_repeat_addr_seq)

  function new(string name = "yapp_repeat_addr_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    bit [1:0] prev_addr;
    `uvm_info("SEQ_START", $sformatf("Executing sequence: %s", get_type_name()), UVM_LOW)

    `uvm_do_with(req, { addr != 3; })
    prev_addr = req.addr;
    `uvm_do_with(req, { addr == prev_addr; })
  endtask : body

endclass : yapp_repeat_addr_seq


// ------------------------------------------------------------------------------
// 6. Incremental Payload Sequence
// ------------------------------------------------------------------------------
class yapp_incr_payload_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_incr_payload_seq)

  function new(string name = "yapp_incr_payload_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info("SEQ_START", $sformatf("Executing sequence: %s", get_type_name()), UVM_LOW)

    `uvm_create(req)
    if (!req.randomize()) begin
      `uvm_fatal("RAND_FAIL", "Failed to randomize packet in yapp_incr_payload_seq")
    end

    foreach (req.payload[i]) begin
      req.payload[i] = i;
    end

    if (req.parity_type == GOOD_PARITY) begin
      req.parity = req.calc_parity();
    end 
    else begin
      do begin
        req.parity = $urandom;
      end while (req.parity == req.calc_parity());
    end

    `uvm_send(req)
  endtask : body

endclass : yapp_incr_payload_seq


// ------------------------------------------------------------------------------
// 7. Random Packet Count Sequence
// ------------------------------------------------------------------------------
class yapp_rnd_seq extends yapp_base_seq;
  rand int count;
  constraint count_limit { count inside {[1:10]}; }

  `uvm_object_utils(yapp_rnd_seq)

  function new(string name = "yapp_rnd_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info("SEQ_START", $sformatf("Executing sequence: %s | Generating %0d random packets", get_type_name(), count), UVM_LOW)
    repeat (count) begin
      `uvm_do(req)
    end
  endtask : body

endclass : yapp_rnd_seq


// ------------------------------------------------------------------------------
// 8. Random Packet Count to 6 Sequence
// ------------------------------------------------------------------------------
class six_yapp_seq extends yapp_base_seq;
  rand int count;
  constraint count_limit { count inside {[1:6]}; }

  `uvm_object_utils(six_yapp_seq)

  function new(string name = "six_yapp_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info("SEQ_START", $sformatf("Executing sequence: %s | Generating %0d random packets", get_type_name(), count), UVM_LOW)
    repeat (count) begin
      `uvm_do(req)
    end
  endtask : body

endclass : six_yapp_seq

// ------------------------------------------------------------------------------
// 9. Optimized Exhaustive Coverage Sweep Sequence (Achieving 100% Coverage)
// ------------------------------------------------------------------------------
class yapp_exhaustive_coverage_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_exhaustive_coverage_seq)

  function new(string name = "yapp_exhaustive_coverage_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing YAPP 100% Coverage Sweep Packets", UVM_HIGH)

    // =========================================================================
    // Step 1: Generate Cross Matrix Sweeps (Valid Addrs x Sizes x BAD_PARITY)
    // =========================================================================
    for (int a = 0; a <= 2; a++) begin
      int target_sizes[] = '{1, 5, 25, 50, 63};
      foreach (target_sizes[i]) begin
        `uvm_do_with(req, { addr == a; length == target_sizes[i]; parity_type == BAD_PARITY; })
      end
    end

    // =========================================================================
    // Step 2: Flood Maximum Length Packets to Trigger Channel "LARGE" Delay Bins
    // =========================================================================
    // Sending a steady stream of max-length packets keeps data_vld asserted long 
    // enough for the reactive slave agent to accumulate a LARGE suspend delay count.
    `uvm_info(get_type_name(), "Flooding max-length packets to hit Channel LARGE delay bins...", UVM_LOW)
    for (int a = 0; a <= 2; a++) begin
      repeat (15) begin
        `uvm_do_with(req, { addr == a; length == 63; parity_type == GOOD_PARITY; })
      end
    end

    // =========================================================================
    // Step 3: Complete 16-Way Back-to-Back Address Transition Sweep (REQ4)
    // =========================================================================
    begin
      // Mathematical De Bruijn sequence covering ALL 16 transition cross pairs 
      // back-to-back for addresses 0, 1, 2, 3:
      int total_transition_addrs[] = '{0, 0, 1, 0, 2, 0, 3, 1, 1, 2, 1, 3, 2, 2, 3, 3, 0};
      
      `uvm_info(get_type_name(), "Executing 16-Way Complete Address Transition Sweep with 0 Delay...", UVM_LOW)
      foreach (total_transition_addrs[idx]) begin
        // CRITICAL: packet_delay must be forced to 0 to enable the monitor's back_to_back flag
        `uvm_do_with(req, { addr == total_transition_addrs[idx]; parity_type == GOOD_PARITY; packet_delay == 0; })
      end
    end

  endtask
endclass
