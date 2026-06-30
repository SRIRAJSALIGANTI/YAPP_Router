// ------------------------------------------------------------------------------
// YAPP Sequence Library Class
// ------------------------------------------------------------------------------
class yapp_seq_lib extends uvm_sequence_library #(yapp_packet);

  // a. Factory registration macro
  `uvm_object_utils(yapp_seq_lib)
  
  // Mandatory auxiliary macro for UVM sequence libraries to populate internal tables
  `uvm_sequence_library_utils(yapp_seq_lib)

  // b. Component constructor
  function new(string name = "yapp_seq_lib");
    super.new(name);
    
    // Initializes the library structure before adding sequences
    init_sequence_library();

    // Statically register your sequence types into this library pool
    add_sequence(yapp_012_seq::get_type());
    add_sequence(yapp_1_seq::get_type());
    add_sequence(yapp_111_seq::get_type());
    add_sequence(yapp_repeat_addr_seq::get_type());
    add_sequence(yapp_incr_payload_seq::get_type());
    add_sequence(yapp_rnd_seq::get_type());
    
  endfunction : new

endclass : yapp_seq_lib
