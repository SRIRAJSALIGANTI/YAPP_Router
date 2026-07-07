//------------------------------------------------------------------------------
// SEQUENCE: router_simple_vseq
//------------------------------------------------------------------------------
class router_simple_vseq extends uvm_sequence;

  // a. Add object macro
  `uvm_object_utils(router_simple_vseq)

  // b. Add uvm_declare_p_sequencer macro to access subsequencer handles
  `uvm_declare_p_sequencer(router_virtual_sequencer)

  // Instance handles for the sub-sequences
  hbus_small_packet_seq small_packet;
  hbus_set_default_regs_seq large_packet;
  hbus_get_yapp_regs_seq   read_regs;
  yapp_012_seq            yapp_012;
  six_yapp_seq            yapp_six;

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

    `uvm_do_on_with(yapp_six, p_sequencer.yapp_seqr, {
      yapp_six.count == 6;
    })

    // 8. Drop the objection on starting_phase
    if (starting_phase != null) begin
      starting_phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "Virtual Sequence Objection Dropped", UVM_MEDIUM)
    end
  endtask : body

endclass : router_simple_vseq
