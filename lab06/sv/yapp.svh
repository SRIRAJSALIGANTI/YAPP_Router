typedef uvm_config_db#(virtual yapp_if) yapp_vif_config;
`include "yapp_packet.sv"
`include "yapp_tx_monitor.sv"
`include "yapp_tx_sequencer.sv"
`include "yapp_tx_seqs.sv"
`include "../tb/yapp_seq_lib.sv"
`include "yapp_tx_driver.sv"
`include "yapp_tx_agent.sv"
`include "yapp_env.sv"
`include "../../Encrypted_Design/Encrypted/yapp_router.svh"
`include "../tb/router_tb.sv"          // <--- ADDED: Must be compiled before the test library
`include "../tb/router_test_lib.sv"
