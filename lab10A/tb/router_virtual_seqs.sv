//------------------------------------------------------------------------------
// SEQUENCE: router_simple_vseq
//------------------------------------------------------------------------------
class router_simple_vseq extends uvm_sequence;

  // a. Add object macro
  `uvm_object_utils(router_simple_vseq)

  // b. Add uvm_declare_p_sequencer macro to access subsequencer handles
  `uvm_declare_p_sequencer(router_virtual_sequencer)

  // Instance handles for the sub-sequences
  hbus_small_packet_seq     small_packet;
  hbus_set_default_regs_seq large_packet;
  hbus_get_yapp_regs_seq    read_regs;
  yapp_012_seq              yapp_012;
  six_yapp_seq              yapp_six;

  // a. Constructor
  function new(string name="router_simple_vseq");
    super.new(name);
  endfunction

  // c. Main virtual sequence body
  virtual task body();
    // 1. Raise an objection on starting_phase
    if (starting_phase != null) begin
      starting_phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "Virtual Sequence Objection Raised", UVM_MEDIUM)
    end

    // 2. Set the router to accept small packets (payload length < 21) and enable it
    `uvm_do_on(small_packet, p_sequencer.hbus_seqr)

    // 3. Read the router MAXPKTSIZE register to make sure it has been correctly set
    `uvm_do_on(read_regs, p_sequencer.hbus_seqr)

    // 4. Send six consecutive packets to address 0, 1, 2, cycling the address
    repeat(6) begin
      `uvm_do_on(yapp_012, p_sequencer.yapp_seqr)
    end

    // 5. Set the router to accept large packets (payload length < 64)
    `uvm_do_on(large_packet, p_sequencer.hbus_seqr)

    // 6. Read the router MAXPKTSIZE register to make sure it has been correctly set
    `uvm_do_on(read_regs, p_sequencer.hbus_seqr)

    // 7. Send a random sequence of six packets
    `uvm_do_on(yapp_six, p_sequencer.yapp_seqr)

    // Drop objection
    if (starting_phase != null) begin
      starting_phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "Virtual Sequence Objection Dropped", UVM_MEDIUM)
    end
  endtask

endclass : router_simple_vseq


//------------------------------------------------------------------------------
// SEQUENCE: router_dynamic_vseq (Lab 10 Parts 1 & 2)
// Description: Configures DUT, sends mixed data profiles, modifies DUT sizing 
//              on-the-fly, and verifies dynamic inline constraint adjustments.
//------------------------------------------------------------------------------
class router_dynamic_vseq extends uvm_sequence;

  `uvm_object_utils(router_dynamic_vseq)
  `uvm_declare_p_sequencer(router_virtual_sequencer)

  // Sub-sequence handles
  hbus_small_packet_seq     small_packet;
  hbus_set_yapp_regs_seq    custom_packet_config; // Flexible sequence to set any value
  yapp_packet               yapp_pkt;

  function new(string name="router_dynamic_vseq");
    super.new(name);
  endfunction

  virtual task body();
    if (starting_phase != null) starting_phase.raise_objection(this);

    // =========================================================================
    // STEP 1: Small Packet Configuration (max_packet_size = 20)
    // =========================================================================
    `uvm_do_on(small_packet, p_sequencer.hbus_seqr)

    // Profile A: Good Parity, Good Size (<= 20)
    `uvm_do_on_with(yapp_pkt, p_sequencer.yapp_seqr, { parity_type == GOOD_PARITY; length <= 20; })
    
    // Profile B: Bad Parity, Good Size (<= 20)
    `uvm_do_on_with(yapp_pkt, p_sequencer.yapp_seqr, { parity_type == BAD_PARITY;  length <= 20; })
    
    // Profile C: Good Parity, BAD SIZE (> 20) -> Valid window is 21 to 63
    `uvm_do_on_with(yapp_pkt, p_sequencer.yapp_seqr, { parity_type == GOOD_PARITY; length > 20;  })


    // =========================================================================
    // STEP 2: Change max_packet_size ON-THE-FLY to 40 
    // =========================================================================
    // We instantiate the base configuration sequence and force it to 40 inline!
    `uvm_do_on_with(custom_packet_config, p_sequencer.hbus_seqr, { max_pkt_reg == 40; enable_reg == 1; })

    // Profile A: Good Parity, Good Size (<= 40)
    `uvm_do_on_with(yapp_pkt, p_sequencer.yapp_seqr, { parity_type == GOOD_PARITY; length <= 40; })
    
    // Profile B: Bad Parity, Good Size (<= 40)
    `uvm_do_on_with(yapp_pkt, p_sequencer.yapp_seqr, { parity_type == BAD_PARITY;  length <= 40; })
    
    // Profile C: Good Parity, BAD SIZE (> 40) -> Valid window is 41 to 63
    // This perfectly proves that the bad size constraint dynamically shifts upwards!
    `uvm_do_on_with(yapp_pkt, p_sequencer.yapp_seqr, { parity_type == GOOD_PARITY; length > 40;  })

    if (starting_phase != null) starting_phase.drop_objection(this);
  endtask

endclass : router_dynamic_vseq

//------------------------------------------------------------------------------
// SEQUENCE: router_disable_enable_vseq (Lab 10 Parts 3 & 4)
//------------------------------------------------------------------------------
class router_disable_enable_vseq extends uvm_sequence;

  `uvm_object_utils(router_disable_enable_vseq)
  `uvm_declare_p_sequencer(router_virtual_sequencer)

  hbus_set_default_regs_seq hbus_default; // Sets max=63, enable=1
  hbus_set_yapp_regs_seq    hbus_config;  // Flexible configuration
  yapp_packet               yapp_pkt;

  function new(string name="router_disable_enable_vseq");
    super.new(name);
  endfunction

  virtual task body();
    if (starting_phase != null) starting_phase.raise_objection(this);

    //--------------------------------------------------------------------------
    // 1. ENABLE IT & SEND PACKETS
    //--------------------------------------------------------------------------
    `uvm_info(get_type_name(), "PHASE 1: Enabling DUT router and sending 10 packets", UVM_LOW)
    `uvm_do_on(hbus_default, p_sequencer.hbus_seqr)
    repeat (12) begin
      `uvm_do_on(yapp_pkt, p_sequencer.yapp_seqr)
    end

    //--------------------------------------------------------------------------
    // 2. DISABLE IT & SEND PACKETS
    //--------------------------------------------------------------------------
    `uvm_info(get_type_name(), "PHASE 2: Disabling DUT router and sending 10 dropped packets", UVM_LOW)
    `uvm_do_on_with(hbus_config, p_sequencer.hbus_seqr, { max_pkt_reg == 63; enable_reg == 0; })
    #500;
    repeat (10) begin
      `uvm_do_on(yapp_pkt, p_sequencer.yapp_seqr)
    end

    //--------------------------------------------------------------------------
    // 3. WAIT
    //--------------------------------------------------------------------------
    `uvm_info(get_type_name(), "PHASE 3: Pausing traffic stream (Idle period)", UVM_LOW)
    #500; 

    //--------------------------------------------------------------------------
    // 4. ENABLE IT & SEND PACKETS
    //--------------------------------------------------------------------------
    `uvm_info(get_type_name(), "PHASE 4: Re-enabling DUT router and sending 10 recovery packets", UVM_LOW)
    `uvm_do_on_with(hbus_config, p_sequencer.hbus_seqr, { max_pkt_reg == 63; enable_reg == 1; })
   // repeat (10) begin
     // `uvm_do_on(yapp_pkt, p_sequencer.yapp_seqr)
    //end

    if (starting_phase != null) starting_phase.drop_objection(this);
  endtask

endclass : router_disable_enable_vseq

//------------------------------------------------------------------------------
// SEQUENCE: router_size_dist_vseq (Lab 10 Parts 6 & 7)
//------------------------------------------------------------------------------
class router_size_dist_vseq extends uvm_sequence;

  `uvm_object_utils(router_size_dist_vseq)
  `uvm_declare_p_sequencer(router_virtual_sequencer)
   
  hbus_set_default_regs_seq hbus_default; // Sets max=63, enable=1

  //hbus_small_packet_seq     small_packet; //20
  yapp_packet               yapp_pkt;

  function new(string name="router_size_dist_vseq");
    super.new(name);
  endfunction

  virtual task body();
    int target_max_size = 63; // Mirroring the default DUT register limit

    if (starting_phase != null) starting_phase.raise_objection(this);

    `uvm_info(get_type_name(), "Starting Packet Size Distribution Sequence", UVM_LOW)

    // 1. Configure the DUT register first so its internal max matches our test
    `uvm_do_on(hbus_default, p_sequencer.hbus_seqr)

    // 2. Generate a large blast of packets (e.g., 50) to observe the distribution statistical curve
    `uvm_info(get_type_name(), "Generating 50 packets with custom size distributions...", UVM_LOW)
    repeat (50) begin
      `uvm_do_on_with(yapp_pkt, p_sequencer.yapp_seqr, {
        length dist {
           (target_max_size - 3)                 :/ 20,  // Weight 20: < (max - 2)
          (target_max_size - 1)                      :/ 30,  // Weight 30: (max - 1)
          (target_max_size)                            :/ 30,  // Weight 30: max_packet_size
          (target_max_size + 3)  :/ 20   // Weight 20: > max_packet_size
        };
      })
    end

    if (starting_phase != null) starting_phase.drop_objection(this);
  endtask

endclass : router_size_dist_vseq
