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

  //----------------------------------------------------------------------------
  // Automatically called by UVM before body() when run as a default_sequence
  //----------------------------------------------------------------------------
  virtual task pre_body();
    if (starting_phase != null) begin
      starting_phase.raise_objection(this);
      `uvm_info(get_type_name(), "Automated Objection RAISED", UVM_MEDIUM)
    end
  endtask : pre_body

  // Main transaction generation loop
  virtual task body();
    `uvm_info(get_type_name(), "exec-yapp_base_seq", UVM_LOW)
    repeat (5) begin
      yapp_packet pkt;
      pkt = yapp_packet::type_id::create("pkt");
      `uvm_do(pkt)
    end
  endtask : body

  //----------------------------------------------------------------------------
  // Automatically called by UVM after body() finishes to allow phase cleanup
  //----------------------------------------------------------------------------
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
