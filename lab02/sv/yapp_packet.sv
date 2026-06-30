// Define enum for parity error injection profiles (1-bit wide)
typedef enum bit { BAD_PARITY, GOOD_PARITY } parity_t;

class yapp_packet extends uvm_sequence_item;

  // Packet Fields
  rand bit [5:0]  length;       // Controls payload size (0 to 63 bytes)
  rand bit [1:0]  addr;         // Target address port/channel for the router
  rand bit [7:0]  payload [];   // Dynamic array to store packet contents
  bit      [7:0]  parity;       

  // Verification control knobs 
  rand parity_t   parity_type;  // Determines whether to inject a parity fault
  rand int        packet_delay; // Simulates inter-packet injection latency

  // UVM Component Constructor
  function new(string name = "yapp_packet");
    super.new(name);
  endfunction

  // UVM Automation Macros (Field Utilities)
  `uvm_object_utils_begin(yapp_packet)
    `uvm_field_int(length,        UVM_ALL_ON)
    `uvm_field_int(addr,          UVM_ALL_ON)
    `uvm_field_array_int(payload, UVM_ALL_ON)
    `uvm_field_int(parity,        UVM_ALL_ON)
    `uvm_field_enum(parity_t, parity_type, UVM_ALL_ON)
    `uvm_field_int(packet_delay,  UVM_ALL_ON | UVM_DEC)
  `uvm_object_utils_end

  // Computes the standard bitwise even parity across the packet structure
  function bit [7:0] calc_parity();
    bit [7:0] local_parity;

    // Initialize parity with the 8-bit packed header byte: {length[5:0], addr[1:0]}
    local_parity = {length, addr}; 
    
    // Progressively XOR down the payload array columns
    foreach (payload[i]) begin
      local_parity = local_parity ^ payload[i];
    end
    
    return local_parity;
  endfunction

  // Automatically runs after the constraint solver finishes picking rand values
  function void post_randomize();
    if (parity_type == GOOD_PARITY) begin
      parity = calc_parity();
    end 
    else begin
      // Keep picking random bytes until we guarantee a corrupted parity match
      do begin
        parity = $urandom;
      end while (parity == calc_parity());
    end
  endfunction
 
  // Restricts length to fit within the protocol's 6-bit hardware limits
  constraint payload_length { length inside {[0:63]}; }
  
  // Synchronizes the physical layout size of the array to match the header length
  constraint payload_size   { payload.size() == length; }
  
  // Keeps simulation delays reasonable (Maximum 20 clock cycles)
  constraint delay          { packet_delay inside {[0 : 20]}; }
  
  // Generates clean packets 83.3% of the time, and injects corrupt errors 16.7% of the time
  constraint parity_default         { parity_type dist {BAD_PARITY := 1, GOOD_PARITY := 5}; }
  
  // Excludes address 2'b11 as it is reserved/invalid in the YAPP specification
  constraint valid_addr     { soft addr != 'b11; }

endclass
