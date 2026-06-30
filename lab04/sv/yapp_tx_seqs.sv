
`ifndef YAPP_5_PACKETS
`define YAPP_5_PACKETS
  class yapp_5_packets extends uvm_sequence #(yapp_packet);

  `uvm_object_utils(yapp_5_packets)

  function new(string name = "yapp_5_packets");
    super.new(name);
  endfunction


  task body();
    repeat (5) begin
      yapp_packet pkt;
      pkt = yapp_packet::type_id::create("pkt");
      `uvm_do(pkt)
    end
  endtask

endclass
`endif
